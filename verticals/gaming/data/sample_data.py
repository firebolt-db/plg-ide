"""
Sample Data Generator for Gaming Vertical

Generates realistic sample data for Firebolt Core (local development)
when S3 access is not available. Uses Firebolt.io Ultra Fast Gaming schema.
"""

import random
from datetime import datetime, timedelta
from pathlib import Path
import sys

# Add lib to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent.parent))

from lib.firebolt import FireboltRunner


# Configuration
NUM_PLAYERS = 10_000
NUM_GAMES = 100
NUM_TOURNAMENTS = 500
NUM_PLAYSTATS = 1_000_000  # 1M events for meaningful benchmarks

# Reference data
PLATFORMS = ["pc", "console", "mobile"]
AGE_CATEGORIES = ["junior", "adult", "senior", "all"]
GENRES = ["fps", "moba", "rpg", "sports", "racing", "puzzle", "strategy", "battle_royale"]
PUBLISHERS = ["Riot Games", "Epic Games", "Valve", "EA Sports", "Ubisoft", "Nintendo", "Activision", "2K Games"]


def generate_players(runner: FireboltRunner, count: int = NUM_PLAYERS):
    """Generate sample player data (Firebolt.io schema)."""
    print(f"Generating {count:,} players...")

    batch_size = 1000
    for batch_start in range(0, count, batch_size):
        batch_end = min(batch_start + batch_size, count)

        values = []
        for i in range(batch_start, batch_end):
            playerid = i + 1
            nickname = f"player_{playerid}"
            email = f"{nickname}@example.com"
            agecategory = random.choice(AGE_CATEGORIES)
            platform = random.choice(PLATFORMS)
            platforms_arr = f"ARRAY['{platform}']"
            registeredon = (datetime.now() - timedelta(days=random.randint(1, 1000))).strftime("%Y-%m-%d")
            issubscribed = "true" if random.random() > 0.5 else "false"
            internalprobabilitytowin = round(random.random(), 4)

            values.append(f"({playerid}, '{nickname}', '{email}', '{agecategory}', {platforms_arr}, '{registeredon}', {issubscribed}, {internalprobabilitytowin})")

        sql = f"""
        INSERT INTO players (playerid, nickname, email, agecategory, platforms, registeredon, issubscribedtonewsletter, internalprobabilitytowin)
        VALUES {', '.join(values)}
        """
        runner.execute(sql)

        if (batch_end) % 5000 == 0:
            print(f"  {batch_end:,} players inserted")

    print(f"  Done: {count:,} players")


def generate_games(runner: FireboltRunner, count: int = NUM_GAMES):
    """Generate sample game data (Firebolt.io schema)."""
    print(f"Generating {count:,} games...")

    values = []
    for i in range(count):
        gameid = i + 1
        title = f"Game_{gameid}_{random.choice(GENRES).title()}"
        category = random.choice(GENRES)
        launchdate = (datetime.now() - timedelta(days=random.randint(30, 2000))).strftime("%Y-%m-%d")

        values.append(f"({gameid}, '{title}', '{category}', '{launchdate}')")

    sql = f"""
    INSERT INTO games (gameid, title, category, launchdate)
    VALUES {', '.join(values)}
    """
    runner.execute(sql)
    print(f"  Done: {count:,} games")


def generate_tournaments(runner: FireboltRunner, count: int = NUM_TOURNAMENTS, num_games: int = NUM_GAMES):
    """Generate sample tournament data (Firebolt.io schema)."""
    print(f"Generating {count:,} tournaments...")

    values = []
    for i in range(count):
        tournamentid = i + 1
        gameid = random.randint(1, num_games)
        name = f"Tournament_{tournamentid}"

        start_date = datetime.now() - timedelta(days=random.randint(1, 365))
        end_date = start_date + timedelta(days=random.randint(1, 14))

        totalprizedollars = random.choice([1000, 5000, 10000, 50000, 100000])

        values.append(f"({tournamentid}, '{name}', {gameid}, {totalprizedollars}, '{start_date}', '{end_date}')")

    sql = f"""
    INSERT INTO tournaments (tournamentid, name, gameid, totalprizedollars, startdatetime, enddatetime)
    VALUES {', '.join(values)}
    """
    runner.execute(sql)
    print(f"  Done: {count:,} tournaments")


def generate_playstats(
    runner: FireboltRunner,
    count: int = NUM_PLAYSTATS,
    num_players: int = NUM_PLAYERS,
    num_games: int = NUM_GAMES,
    num_tournaments: int = NUM_TOURNAMENTS
):
    """Generate sample playstats data (Firebolt.io schema - no stat_id)."""
    print(f"Generating {count:,} playstats events...")

    batch_size = 10000
    for batch_start in range(0, count, batch_size):
        batch_end = min(batch_start + batch_size, count)

        values = []
        for i in range(batch_start, batch_end):
            playerid = random.randint(1, num_players)
            gameid = random.randint(1, num_games)
            tournamentid = random.randint(1, num_tournaments)

            stattime = datetime.now() - timedelta(
                days=random.randint(0, 90),
                hours=random.randint(0, 23),
                minutes=random.randint(0, 59)
            )

            selectedcar = f"car_{random.randint(1, 10)}"
            currentlevel = random.randint(1, 100)
            currentspeed = round(random.uniform(0, 200), 1)
            currentplaytime = random.randint(60, 7200)
            currentscore = random.randint(0, 10000)
            event = "play"

            values.append(
                f"({gameid}, {playerid}, '{stattime}', '{selectedcar}', {currentlevel}, {currentspeed}, "
                f"{currentplaytime}, {currentscore}, '{event}', NULL, {tournamentid})"
            )

        sql = f"""
        INSERT INTO playstats (gameid, playerid, stattime, selectedcar, currentlevel, currentspeed,
                               currentplaytime, currentscore, event, errorcode, tournamentid)
        VALUES {', '.join(values)}
        """
        runner.execute(sql)

        if (batch_end) % 100000 == 0:
            print(f"  {batch_end:,} playstats inserted")

    print(f"  Done: {count:,} playstats")


def main():
    """Generate all sample data."""
    print("=" * 60)
    print("Gaming Vertical Sample Data Generator (Firebolt.io schema)")
    print("=" * 60)

    runner = FireboltRunner()

    # Create database
    runner.create_database_if_not_exists()

    # Create tables first
    print("\nCreating tables...")
    schema_path = Path(__file__).parent.parent / "schema" / "01_tables.sql"
    runner.execute_file(schema_path)

    # Generate data
    print("\nGenerating sample data...")
    generate_games(runner)
    generate_players(runner)
    generate_tournaments(runner)
    generate_playstats(runner)

    # Verify
    print("\n" + "=" * 60)
    print("Verification")
    print("=" * 60)

    result = runner.execute("""
        SELECT 'players' as table_name, COUNT(*) as row_count FROM players
        UNION ALL SELECT 'games', COUNT(*) FROM games
        UNION ALL SELECT 'tournaments', COUNT(*) FROM tournaments
        UNION ALL SELECT 'playstats', COUNT(*) FROM playstats
    """)

    for row in result.data:
        print(f"  {row['table_name']}: {int(row['row_count']):,} rows")

    print("\nSample data generation complete!")
    runner.close()


if __name__ == "__main__":
    main()
