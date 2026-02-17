"""
Sample Data Generator for CyberTech Vertical

Generates synthetic multi-cloud security audit log events for Firebolt Core
(local development) when S3 access is not available. Includes controlled
anomaly injection for anomaly detection demos.
"""

import os
import random
from datetime import datetime, timedelta
from pathlib import Path
import sys

# Default database for CyberTech vertical (override with FIREBOLT_DATABASE env)
os.environ.setdefault("FIREBOLT_DATABASE", "cybertech")

# Add lib to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent.parent))

from lib.firebolt import FireboltRunner


# Configuration
NUM_EVENTS_PER_TABLE = 100_000  # ~100K events per table for meaningful benchmarks

# AWS CloudTrail event types (name, weight, is_destructive)
AWS_EVENTS = [
    ("DescribeInstances", 0.25), ("GetObject", 0.15), ("PutObject", 0.10),
    ("ListBuckets", 0.10), ("ConsoleLogin", 0.08), ("StartInstances", 0.08),
    ("StopInstances", 0.08), ("RunInstances", 0.05), ("DeleteInstance", 0.02),
    ("DeleteSecurityGroup", 0.02), ("DeleteObject", 0.01),
]

# Azure Activity Log event types
AZURE_EVENTS = [
    ("Microsoft.Compute/virtualMachines/read", 0.25),
    ("Microsoft.Storage/storageAccounts/read", 0.15),
    ("Microsoft.Compute/virtualMachines/start/action", 0.12),
    ("Microsoft.Compute/virtualMachines/deallocate/action", 0.10),
    ("Microsoft.Compute/virtualMachines/delete", 0.05),
    ("Microsoft.Storage/storageAccounts/delete", 0.04),
]

# GCP Audit Log event types
GCP_EVENTS = [
    ("compute.instances.get", 0.25), ("storage.objects.get", 0.15),
    ("compute.instances.start", 0.12), ("compute.instances.stop", 0.10),
    ("compute.instances.delete", 0.05), ("storage.buckets.delete", 0.04),
]

# Synthetic usernames for anomaly demo (2 spike users per cloud get higher delete rate)
AWS_USERS = [f"user.aws_{i}" for i in range(1, 31)] + ["contractor.alex", "service.account.deploy"]
AZURE_USERS = [f"user.azure_{i}" for i in range(1, 26)] + ["bob.martinez", "carlos.contractor"]
GCP_USERS = [f"user.gcp_{i}" for i in range(1, 21)] + ["eve.developer", "dana.admin"]


def _escape(s: str) -> str:
    """Escape single quotes for SQL."""
    return s.replace("'", "''") if s else ""


def _weighted_choice(events: list) -> str:
    """Select event by weight."""
    r = random.random()
    cum = 0
    for name, weight in events:
        cum += weight
        if r <= cum:
            return name
    return events[-1][0]


def _generate_events(
    runner: FireboltRunner,
    table: str,
    events_list: list,
    users: list,
    count: int,
    event_source_prefix: str,
    instance_prefix: str,
    spike_users: list,
):
    """Generate events for a cloud table with anomaly injection."""
    print(f"Generating {count:,} events for {table}...")

    batch_size = 5000
    for batch_start in range(0, count, batch_size):
        batch_end = min(batch_start + batch_size, count)
        values = []

        for _ in range(batch_start, batch_end):
            user = random.choice(users)
            ts = datetime.now() - timedelta(
                days=random.randint(0, 30),
                hours=random.randint(0, 23),
                minutes=random.randint(0, 59),
            )
            event_time = ts.strftime("%Y-%m-%d %H:%M:%S")

            # Anomaly injection: spike users have higher delete probability during some hours
            is_spike = user in spike_users and ts.hour in (9, 14, 22)
            if is_spike and random.random() < 0.15:
                # Force a delete event during spike
                destructive = [e for e in events_list if "delete" in e[0].lower() or "Delete" in e[0]]
                event_name = random.choice(destructive)[0] if destructive else events_list[-1][0]
            else:
                event_name = _weighted_choice(events_list)

            event_source = f"{event_source_prefix}.com"
            source_ip = f"10.{random.randint(0, 255)}.{random.randint(0, 255)}.{random.randint(1, 254)}"
            instance_id = f"{instance_prefix}{random.randint(1000, 9999)}"

            values.append(
                f"('{event_time}', '{_escape(event_name)}', '{event_source}', "
                f"'{_escape(user)}', '{source_ip}', '{instance_id}', NULL, NULL, NULL)"
            )

        sql = f"""
        INSERT INTO {table} (event_time, event_name, event_source, username, source_ip, instance_id, current_state, previous_state, src)
        VALUES {', '.join(values)}
        """
        runner.execute(sql)

        if batch_end % 25000 == 0:
            print(f"  {batch_end:,} events inserted")

    print(f"  Done: {count:,} events in {table}")


def main():
    """Generate all sample data."""
    print("=" * 60)
    print("CyberTech Vertical Sample Data Generator")
    print("=" * 60)

    runner = FireboltRunner()

    # Create database (FIREBOLT_DATABASE defaults to cybertech for this script)
    runner.create_database_if_not_exists("cybertech")

    # Create tables first
    print("\nCreating tables...")
    schema_path = Path(__file__).parent.parent / "schema" / "01_tables.sql"
    runner.execute_file(schema_path)

    # Generate data
    print("\nGenerating sample data (with anomaly injection)...")
    _generate_events(
        runner, "events", AWS_EVENTS, AWS_USERS, NUM_EVENTS_PER_TABLE,
        "ec2.amazonaws", "i-", ["contractor.alex", "service.account.deploy"],
    )
    _generate_events(
        runner, "azure_events", AZURE_EVENTS, AZURE_USERS, NUM_EVENTS_PER_TABLE,
        "microsoft.compute", "vm-", ["bob.martinez", "carlos.contractor"],
    )
    _generate_events(
        runner, "gcp_events", GCP_EVENTS, GCP_USERS, NUM_EVENTS_PER_TABLE,
        "compute.googleapis", "gce-", ["eve.developer", "dana.admin"],
    )

    # Verify
    print("\n" + "=" * 60)
    print("Verification")
    print("=" * 60)

    result = runner.execute("""
        SELECT 'events' as table_name, COUNT(*) as row_count FROM events
        UNION ALL SELECT 'azure_events', COUNT(*) FROM azure_events
        UNION ALL SELECT 'gcp_events', COUNT(*) FROM gcp_events
    """)

    for row in result.data:
        print(f"  {row['table_name']}: {int(row['row_count']):,} rows")

    print("\nSample data generation complete!")
    runner.close()


if __name__ == "__main__":
    main()
