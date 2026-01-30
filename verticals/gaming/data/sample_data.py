"""
Sample Data Generator for Gaming Vertical

Generates realistic sample data for Firebolt Core (local development)
when S3 access is not available.
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
SUBSCRIPTION_TYPES = ["free", "premium", "pro"]
COUNTRIES = ["US", "UK", "DE", "FR", "JP", "KR", "BR", "IN", "AU", "CA"]
GENRES = ["fps", "moba", "rpg", "sports", "racing", "puzzle", "strategy", "battle_royale"]
PUBLISHERS = ["Riot Games", "Epic Games", "Valve", "EA Sports", "Ubisoft", "Nintendo", "Activision", "2K Games"]


def generate_players(runner: FireboltRunner, count: int = NUM_PLAYERS):
    """Generate sample player data."""
    print(f"Generating {count:,} players...")
    
    batch_size = 1000
    for batch_start in range(0, count, batch_size):
        batch_end = min(batch_start + batch_size, count)
        
        values = []
        for i in range(batch_start, batch_end):
            player_id = i + 1
            username = f"player_{player_id}"
            email = f"{username}@example.com"
            reg_date = (datetime.now() - timedelta(days=random.randint(1, 1000))).strftime("%Y-%m-%d")
            subscription = random.choice(SUBSCRIPTION_TYPES)
            country = random.choice(COUNTRIES)
            platform = random.choice(PLATFORMS)
            
            values.append(f"({player_id}, '{username}', '{email}', '{reg_date}', '{subscription}', '{country}', '{platform}')")
        
        sql = f"""
        INSERT INTO players (player_id, username, email, registration_date, subscription_type, country, platform)
        VALUES {', '.join(values)}
        """
        runner.execute(sql)
        
        if (batch_end) % 5000 == 0:
            print(f"  {batch_end:,} players inserted")
    
    print(f"  Done: {count:,} players")


def generate_games(runner: FireboltRunner, count: int = NUM_GAMES):
    """Generate sample game data."""
    print(f"Generating {count:,} games...")
    
    values = []
    for i in range(count):
        game_id = i + 1
        game_name = f"Game_{game_id}_{random.choice(GENRES).title()}"
        genre = random.choice(GENRES)
        publisher = random.choice(PUBLISHERS)
        release_date = (datetime.now() - timedelta(days=random.randint(30, 2000))).strftime("%Y-%m-%d")
        rating = round(random.uniform(3.0, 5.0), 1)
        
        values.append(f"({game_id}, '{game_name}', '{genre}', '{publisher}', '{release_date}', {rating})")
    
    sql = f"""
    INSERT INTO games (game_id, game_name, genre, publisher, release_date, rating)
    VALUES {', '.join(values)}
    """
    runner.execute(sql)
    print(f"  Done: {count:,} games")


def generate_tournaments(runner: FireboltRunner, count: int = NUM_TOURNAMENTS, num_games: int = NUM_GAMES):
    """Generate sample tournament data."""
    print(f"Generating {count:,} tournaments...")
    
    values = []
    for i in range(count):
        tournament_id = i + 1
        game_id = random.randint(1, num_games)
        tournament_name = f"Tournament_{tournament_id}"
        
        start_date = datetime.now() - timedelta(days=random.randint(1, 365))
        end_date = start_date + timedelta(days=random.randint(1, 14))
        
        prize_pool = random.choice([1000, 5000, 10000, 50000, 100000])
        status = "completed" if end_date < datetime.now() else ("active" if start_date < datetime.now() else "upcoming")
        
        values.append(f"({tournament_id}, {game_id}, '{tournament_name}', '{start_date}', '{end_date}', {prize_pool}, '{status}')")
    
    sql = f"""
    INSERT INTO tournaments (tournament_id, game_id, tournament_name, start_date, end_date, prize_pool, status)
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
    """Generate sample playstats data (the high-volume fact table)."""
    print(f"Generating {count:,} playstats events...")
    
    batch_size = 10000
    for batch_start in range(0, count, batch_size):
        batch_end = min(batch_start + batch_size, count)
        
        values = []
        for i in range(batch_start, batch_end):
            stat_id = i + 1
            player_id = random.randint(1, num_players)
            game_id = random.randint(1, num_games)
            tournament_id = random.randint(1, num_tournaments)
            
            stat_time = datetime.now() - timedelta(
                days=random.randint(0, 90),
                hours=random.randint(0, 23),
                minutes=random.randint(0, 59)
            )
            
            current_score = random.randint(0, 10000)
            current_level = random.randint(1, 100)
            current_play_time = random.randint(60, 7200)  # 1 min to 2 hours
            platform = random.choice(PLATFORMS)
            session_id = f"sess_{stat_id}"
            
            values.append(
                f"({stat_id}, {player_id}, {game_id}, {tournament_id}, "
                f"'{stat_time}', {current_score}, {current_level}, {current_play_time}, "
                f"'{platform}', '{session_id}')"
            )
        
        sql = f"""
        INSERT INTO playstats (stat_id, player_id, game_id, tournament_id, stat_time, 
                               current_score, current_level, current_play_time, platform, session_id)
        VALUES {', '.join(values)}
        """
        runner.execute(sql)
        
        if (batch_end) % 100000 == 0:
            print(f"  {batch_end:,} playstats inserted")
    
    print(f"  Done: {count:,} playstats")


def main():
    """Generate all sample data."""
    print("=" * 60)
    print("Gaming Vertical Sample Data Generator")
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
