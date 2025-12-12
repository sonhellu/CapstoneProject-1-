#!/usr/bin/env python3
"""
Seed initial data for database
Run: python3 seed_data.py
"""

import sys
import os

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app import create_app
from app.database import db
from app.models import Schools, Colleges, Departments, Language, Country

def seed_data():
    """Seed initial data into database"""
    app = create_app()
    
    with app.app_context():
        print("🌱 Starting to seed database...\n")
        
        # 1. Seed Languages
        print("📝 Seeding Languages...")
        languages = [
            Language(code='en', name='English', native_name='English'),
            Language(code='ko', name='Korean', native_name='한국어'),
            Language(code='vi', name='Vietnamese', native_name='Tiếng Việt'),
            Language(code='zh', name='Chinese', native_name='中文'),
            Language(code='ja', name='Japanese', native_name='日本語'),
            Language(code='my', name='Myanmar', native_name='မြန်မာ'),
        ]
        
        for lang in languages:
            if not Language.query.get(lang.code):
                db.session.add(lang)
                print(f"  ✅ Added language: {lang.code} - {lang.name}")
            else:
                print(f"  ⚠️  Language {lang.code} already exists")
        
        # 2. Seed Countries
        print("\n🌍 Seeding Countries...")
        countries = [
            Country(iso2='US', name='United States'),
            Country(iso2='KR', name='South Korea'),
            Country(iso2='VN', name='Vietnam'),
            Country(iso2='CN', name='China'),
            Country(iso2='JP', name='Japan'),
            Country(iso2='MM', name='Myanmar'),
            Country(iso2='TH', name='Thailand'),
            Country(iso2='ID', name='Indonesia'),
            Country(iso2='PH', name='Philippines'),
            Country(iso2='SG', name='Singapore'),
        ]
        
        for country in countries:
            if not Country.query.get(country.iso2):
                db.session.add(country)
                print(f"  ✅ Added country: {country.iso2} - {country.name}")
            else:
                print(f"  ⚠️  Country {country.iso2} already exists")
        
        # 3. Seed Schools
        print("\n🏫 Seeding Schools...")
        schools = [
            Schools(id=5917654, school_name='Test University', website_url='https://example.com'),
            Schools(id=1, school_name='Keimyung University', website_url='https://www.kmu.ac.kr'),
            Schools(id=2, school_name='Seoul National University', website_url='https://www.snu.ac.kr'),
            Schools(id=3, school_name='Korea University', website_url='https://www.korea.ac.kr'),
            Schools(id=4, school_name='Yonsei University', website_url='https://www.yonsei.ac.kr'),
            Schools(id=5, school_name='KAIST', website_url='https://www.kaist.ac.kr'),
            Schools(id=6, school_name='Sungkyunkwan University', website_url='https://www.skku.edu'),
            Schools(id=7, school_name='Hongik University', website_url='https://www.hongik.ac.kr'),
            Schools(id=8, school_name='Hanyang University', website_url='https://www.hanyang.ac.kr'),
            Schools(id=9, school_name='Chung-Ang University', website_url='https://www.cau.ac.kr'),
            Schools(id=10, school_name='Kyung Hee University', website_url='https://www.khu.ac.kr'),
            Schools(id=11, school_name='Ewha Womans University', website_url='https://www.ewha.ac.kr'),
            Schools(id=12, school_name='Sogang University', website_url='https://www.sogang.ac.kr'),
            Schools(id=13, school_name='Pusan National University', website_url='https://www.pnu.ac.kr'),
            Schools(id=14, school_name='Inha University', website_url='https://www.inha.ac.kr'),
            Schools(id=15, school_name='Other University', website_url=''),
        ]
        
        for school in schools:
            existing = Schools.query.get(school.id)
            if not existing:
                db.session.add(school)
                print(f"  ✅ Added school: {school.id} - {school.school_name}")
            else:
                # Update school name if different
                if existing.school_name != school.school_name:
                    existing.school_name = school.school_name
                    existing.website_url = school.website_url
                    print(f"  🔄 Updated school: {school.id} - {school.school_name}")
                else:
                    print(f"  ⚠️  School {school.id} already exists: {existing.school_name}")
        
        db.session.flush()  # Get IDs for colleges
        
        # 4. Seed Colleges
        print("\n🎓 Seeding Colleges...")
        colleges_data = [
            {'school_id': 5917654, 'name': 'College of Engineering'},
            {'school_id': 5917654, 'name': 'College of Arts'},
            {'school_id': 5917654, 'name': 'College of Business'},
            {'school_id': 1, 'name': 'College of Engineering'},
            {'school_id': 1, 'name': 'College of Liberal Arts'},
            {'school_id': 2, 'name': 'College of Engineering'},
            {'school_id': 2, 'name': 'College of Medicine'},
        ]
        
        for college_data in colleges_data:
            existing = Colleges.query.filter_by(
                school_id=college_data['school_id'],
                college_name=college_data['name']
            ).first()
            if not existing:
                college = Colleges(
                    school_id=college_data['school_id'],
                    college_name=college_data['name']
                )
                db.session.add(college)
                print(f"  ✅ Added college: {college_data['name']} (School ID: {college_data['school_id']})")
            else:
                print(f"  ⚠️  College {college_data['name']} already exists")
        
        db.session.flush()  # Get IDs for departments
        
        # 5. Seed Departments
        print("\n📚 Seeding Departments...")
        
        # Create a general "General Studies" college for each school to host common departments
        # This ensures departments are available across all schools
        general_colleges = {}
        for school in Schools.query.all():
            general_college = Colleges.query.filter_by(
                school_id=school.id,
                college_name='General Studies'
            ).first()
            if not general_college:
                general_college = Colleges(
                    school_id=school.id,
                    college_name='General Studies'
                )
                db.session.add(general_college)
                db.session.flush()
            general_colleges[school.id] = general_college
        
        db.session.flush()
        
        # All departments that frontend expects (20 departments)
        all_departments = [
            'Computer Science',
            'Business Administration',
            'Engineering',
            'Liberal Arts',
            'Medicine',
            'Law',
            'Fine Arts',
            'Music',
            'Physical Education',
            'Natural Sciences',
            'International Studies',
            'Media & Communication',
            'Architecture',
            'Culinary Arts',
            'Early Childhood Education',
            'Environmental Science',
            'Psychology',
            'Economics',
            'Information Technology',
            'Theater & Film',
        ]
        
        # Add all departments to all schools
        departments_added = 0
        for school in Schools.query.all():
            general_college = general_colleges.get(school.id)
            if general_college:
                for dept_name in all_departments:
                    # Check if department already exists for this school
                    existing = Departments.query.filter_by(
                        school_id=school.id,
                        department_name=dept_name
                    ).first()
                    
                    if not existing:
                        dept = Departments(
                            school_id=school.id,
                            college_id=general_college.id,
                            department_name=dept_name
                        )
                        db.session.add(dept)
                        departments_added += 1
                        if departments_added <= 5:  # Print first 5 only to avoid spam
                            print(f"  ✅ Added department: {dept_name} (School: {school.school_name})")
        
        if departments_added > 5:
            print(f"  ✅ Added {departments_added} departments across all schools")
        else:
            print(f"  ⚠️  All departments already exist or no new departments added")
        
        # Commit all changes
        try:
            db.session.commit()
            print("\n✅ All data seeded successfully!")
            print("\n📊 Summary:")
            print(f"  - Languages: {Language.query.count()}")
            print(f"  - Countries: {Country.query.count()}")
            print(f"  - Schools: {Schools.query.count()}")
            print(f"  - Colleges: {Colleges.query.count()}")
            print(f"  - Departments: {Departments.query.count()}")
        except Exception as e:
            db.session.rollback()
            print(f"\n❌ Error seeding data: {e}")
            import traceback
            traceback.print_exc()
            raise

if __name__ == "__main__":
    seed_data()

