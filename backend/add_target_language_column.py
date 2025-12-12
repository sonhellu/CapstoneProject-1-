#!/usr/bin/env python3
"""
Script để thêm cột target_language vào bảng match_requests
Chạy: python3 add_target_language_column.py
"""

import sys
import os

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app import create_app
from app.database import db

def add_target_language_column():
    """Add target_language column to match_requests table"""
    app = create_app()
    
    with app.app_context():
        try:
            database_url = os.getenv("DATABASE_URL", "")
            is_postgresql = database_url.startswith("postgresql://") or database_url.startswith("postgres://")
            
            print("🔍 Checking if target_language column exists...")
            
            # Check if column exists
            if is_postgresql:
                result = db.session.execute(db.text("""
                    SELECT 1 FROM information_schema.columns 
                    WHERE table_name = 'match_requests' AND column_name = 'target_language'
                """))
                exists = result.fetchone() is not None
            else:
                # MySQL
                result = db.session.execute(db.text("SHOW COLUMNS FROM match_requests LIKE 'target_language'"))
                exists = result.fetchone() is not None
            
            if exists:
                print("✅ Column target_language already exists!")
                return
            
            print("📝 Adding target_language column...")
            
            # Add column as nullable first
            if is_postgresql:
                # PostgreSQL: Add column as nullable first
                print("  → Adding column (nullable)...")
                db.session.execute(db.text("""
                    ALTER TABLE match_requests 
                    ADD COLUMN target_language VARCHAR(10)
                """))
                db.session.commit()
                
                # Set default value for existing rows (use 'ko' as default)
                print("  → Setting default value for existing rows...")
                db.session.execute(db.text("""
                    UPDATE match_requests 
                    SET target_language = 'ko' 
                    WHERE target_language IS NULL
                """))
                db.session.commit()
                
                # Add foreign key constraint
                print("  → Adding foreign key constraint...")
                try:
                    db.session.execute(db.text("""
                        ALTER TABLE match_requests 
                        ADD CONSTRAINT match_requests_target_language_fkey 
                        FOREIGN KEY (target_language) REFERENCES language(code)
                    """))
                    db.session.commit()
                except Exception as e:
                    print(f"  ⚠️  Foreign key constraint may already exist: {e}")
                    db.session.rollback()
                
                # Make NOT NULL after setting defaults
                print("  → Making column NOT NULL...")
                db.session.execute(db.text("""
                    ALTER TABLE match_requests 
                    ALTER COLUMN target_language SET NOT NULL
                """))
                db.session.commit()
            else:
                # MySQL
                print("  → Adding column (nullable)...")
                db.session.execute(db.text("""
                    ALTER TABLE match_requests 
                    ADD COLUMN target_language VARCHAR(10) NULL AFTER requester_user_id
                """))
                db.session.commit()
                
                # Set default value for existing rows
                print("  → Setting default value for existing rows...")
                db.session.execute(db.text("""
                    UPDATE match_requests 
                    SET target_language = 'ko' 
                    WHERE target_language IS NULL
                """))
                db.session.commit()
                
                # Add foreign key constraint
                print("  → Adding foreign key constraint...")
                try:
                    db.session.execute(db.text("""
                        ALTER TABLE match_requests 
                        ADD CONSTRAINT match_requests_target_language_fkey 
                        FOREIGN KEY (target_language) REFERENCES language(code)
                    """))
                    db.session.commit()
                except Exception as e:
                    print(f"  ⚠️  Foreign key constraint may already exist: {e}")
                    db.session.rollback()
                
                # Make NOT NULL
                print("  → Making column NOT NULL...")
                db.session.execute(db.text("""
                    ALTER TABLE match_requests 
                    MODIFY COLUMN target_language VARCHAR(10) NOT NULL
                """))
                db.session.commit()
            
            print("✅ Successfully added target_language column!")
            
        except Exception as e:
            db.session.rollback()
            print(f"❌ Error: {e}")
            import traceback
            traceback.print_exc()
            sys.exit(1)

if __name__ == "__main__":
    add_target_language_column()

