#!/usr/bin/env python3
"""
Athlete Merger Script

This script merges athlete data by updating all foreign key references
from an unknown athlete to a known athlete, then deletes the unknown athlete.

Usage:
    python scripts/merge_athletes.py --unknown "Aaron Unknown" --known "Aaron Bratt"
    python scripts/merge_athletes.py --unknown-id 240 --known-id 230
    python scripts/merge_athletes.py --mappings "Aaron Unknown->Aaron Bratt" "Arthur Unknown->Arthur Beyer"
"""

import argparse
import psycopg2
import sys
from typing import Dict, Tuple, Optional


class AthleteMerger:
    def __init__(self, db_config: Dict[str, str]):
        self.db_config = db_config
        self.conn = None

    def connect(self):
        """Connect to the PostgreSQL database"""
        try:
            self.conn = psycopg2.connect(**self.db_config)
            self.conn.autocommit = False  # Use transactions
            print("Connected to database successfully")
        except Exception as e:
            print(f"Failed to connect to database: {e}")
            sys.exit(1)

    def disconnect(self):
        """Close database connection"""
        if self.conn:
            self.conn.close()
            print("Database connection closed")

    def get_athlete_id_by_name(self, name: str) -> Optional[int]:
        """Get athlete ID by name"""
        with self.conn.cursor() as cur:
            cur.execute("SELECT id FROM athletes WHERE name = %s", (name,))
            result = cur.fetchone()
            return result[0] if result else None

    def get_athlete_name_by_id(self, athlete_id: int) -> Optional[str]:
        """Get athlete name by ID"""
        with self.conn.cursor() as cur:
            cur.execute("SELECT name FROM athletes WHERE id = %s", (athlete_id,))
            result = cur.fetchone()
            return result[0] if result else None

    def validate_athletes(self, unknown_id: Optional[int] = None, unknown_name: Optional[str] = None,
                         known_id: Optional[int] = None, known_name: Optional[str] = None) -> Tuple[int, int]:
        """Validate that both athletes exist and return their IDs"""

        # Get unknown athlete ID
        if unknown_id:
            unknown_athlete_name = self.get_athlete_name_by_id(unknown_id)
            if not unknown_athlete_name:
                raise ValueError(f"Unknown athlete with ID {unknown_id} not found")
        elif unknown_name:
            unknown_id = self.get_athlete_id_by_name(unknown_name)
            if not unknown_id:
                raise ValueError(f"Unknown athlete '{unknown_name}' not found")
            unknown_athlete_name = unknown_name
        else:
            raise ValueError("Must provide either unknown_id or unknown_name")

        # Get known athlete ID
        if known_id:
            known_athlete_name = self.get_athlete_name_by_id(known_id)
            if not known_athlete_name:
                raise ValueError(f"Known athlete with ID {known_id} not found")
        elif known_name:
            known_id = self.get_athlete_id_by_name(known_name)
            if not known_id:
                raise ValueError(f"Known athlete '{known_name}' not found")
            known_athlete_name = known_name
        else:
            raise ValueError("Must provide either known_id or known_name")

        if unknown_id == known_id:
            raise ValueError("Cannot merge athlete with itself")

        print(f"Merging: {unknown_athlete_name} (ID: {unknown_id}) -> {known_athlete_name} (ID: {known_id})")
        return unknown_id, known_id

    def merge_athletes(self, unknown_id: int, known_id: int) -> bool:
        """Merge unknown athlete data into known athlete and delete unknown athlete"""
        try:
            with self.conn.cursor() as cur:
                # First, handle potential nickname conflicts by removing duplicates
                # Find nicknames that would conflict after the merge
                cur.execute("""
                    SELECT an1.id
                    FROM athlete_nicknames an1
                    INNER JOIN athlete_nicknames an2 ON an1.nickname = an2.nickname
                    WHERE an1.athlete_id = %s AND an2.athlete_id = %s
                """, (unknown_id, known_id))
                
                conflicting_nickname_ids = [row[0] for row in cur.fetchall()]
                if conflicting_nickname_ids:
                    cur.execute("""
                        DELETE FROM athlete_nicknames 
                        WHERE id = ANY(%s)
                    """, (conflicting_nickname_ids,))
                    print(f"Removed {len(conflicting_nickname_ids)} conflicting nicknames")

                # Update athlete_nicknames
                cur.execute("""
                    UPDATE athlete_nicknames
                    SET athlete_id = %s
                    WHERE athlete_id = %s
                """, (known_id, unknown_id))
                nicknames_updated = cur.rowcount
                print(f"Updated {nicknames_updated} athlete nicknames")

                # Update race_results
                cur.execute("""
                    UPDATE race_results
                    SET athlete_id = %s
                    WHERE athlete_id = %s
                """, (known_id, unknown_id))
                race_results_updated = cur.rowcount
                print(f"Updated {race_results_updated} race results")

                # Update review_flags
                cur.execute("""
                    UPDATE review_flags
                    SET matched_athlete_id = %s
                    WHERE matched_athlete_id = %s
                """, (known_id, unknown_id))
                review_flags_updated = cur.rowcount
                print(f"Updated {review_flags_updated} review flags")

                # Delete the unknown athlete (CASCADE will handle athlete_nicknames)
                cur.execute("DELETE FROM athletes WHERE id = %s", (unknown_id,))
                athletes_deleted = cur.rowcount
                print(f"Deleted {athletes_deleted} athlete record")

                # Commit the transaction
                self.conn.commit()
                print("Transaction committed successfully")
                return True

        except Exception as e:
            self.conn.rollback()
            print(f"Error during merge: {e}")
            return False

    def process_mappings(self, mappings: list) -> int:
        """Process multiple athlete mappings"""
        success_count = 0

        for mapping in mappings:
            try:
                if '->' in mapping:
                    # Parse "Unknown Name->Known Name" format
                    unknown_name, known_name = mapping.split('->', 1)
                    unknown_name = unknown_name.strip()
                    known_name = known_name.strip()

                    unknown_id, known_id = self.validate_athletes(
                        unknown_name=unknown_name, known_name=known_name
                    )

                else:
                    raise ValueError(f"Invalid mapping format: {mapping}. Use 'Unknown Name->Known Name'")

                if self.merge_athletes(unknown_id, known_id):
                    success_count += 1
                    print(f"✓ Successfully merged {unknown_name} -> {known_name}")
                else:
                    print(f"✗ Failed to merge {unknown_name} -> {known_name}")

            except ValueError as e:
                print(f"✗ Validation error for mapping '{mapping}': {e}")
            except Exception as e:
                print(f"✗ Unexpected error for mapping '{mapping}': {e}")

            print("-" * 50)

        return success_count


def main():
    parser = argparse.ArgumentParser(description="Merge athlete data from unknown to known athletes")
    parser.add_argument('--unknown', help='Name of the unknown athlete to merge from')
    parser.add_argument('--known', help='Name of the known athlete to merge into')
    parser.add_argument('--unknown-id', type=int, help='ID of the unknown athlete to merge from')
    parser.add_argument('--known-id', type=int, help='ID of the known athlete to merge into')
    parser.add_argument('--mappings', nargs='*', help='List of mappings in format "Unknown Name->Known Name"')

    args = parser.parse_args()

    # Database configuration (same as Go app)
    db_config = {
        'host': 'localhost',
        'port': '5432',
        'user': 'grcuser',
        'password': 'grcpass',
        'database': 'grcdb'
    }

    merger = AthleteMerger(db_config)
    merger.connect()

    try:
        if args.mappings:
            # Process multiple mappings
            success_count = merger.process_mappings(args.mappings)
            print(f"\nProcessed {len(args.mappings)} mappings, {success_count} successful")

        elif args.unknown or args.unknown_id or args.known or args.known_id:
            # Process single mapping
            unknown_id, known_id = merger.validate_athletes(
                unknown_id=args.unknown_id,
                unknown_name=args.unknown,
                known_id=args.known_id,
                known_name=args.known
            )

            if merger.merge_athletes(unknown_id, known_id):
                print("✓ Athlete merge completed successfully")
            else:
                print("✗ Athlete merge failed")
                sys.exit(1)

        else:
            parser.print_help()
            sys.exit(1)

    finally:
        merger.disconnect()


if __name__ == '__main__':
    main()