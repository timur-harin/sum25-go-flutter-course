#!/usr/bin/env python3
"""
Simple Peer Review Assignment Script for Go+Flutter Course

This script assigns 2 reviewers for each student by rotating through the student list.
"""

import csv
from typing import List
from dataclasses import dataclass

@dataclass
class Student:
    first_name: str
    last_name: str
    email: str
    groups: str
    
    @property
    def full_name(self) -> str:
        return f"{self.last_name} {self.first_name}"
    
    def branch_name(self, lab_number: int) -> str:
        """Generate branch name format: labXX-lastname-firstname"""
        return f"lab{lab_number:02d}-{self.last_name.lower()}-{self.first_name.lower()}"

def assign_reviewers_simple(students: List[Student], lab_number: int) -> dict:
    """
    Simple assignment: each student gets the next 2 students in the list as reviewers.
    Rotates through the list with offset based on lab number.
    """
    assignments = {}
    n = len(students)
    
    for i, student in enumerate(students):
        # Calculate reviewer indices with rotation based on lab number
        offset = (lab_number - 1) * 2  # Different offset for each lab
        reviewer1_idx = (i + 1 + offset) % n
        reviewer2_idx = (i + 2 + offset) % n
        
        # Skip self-review
        if reviewer1_idx == i:
            reviewer1_idx = (reviewer1_idx + 1) % n
        if reviewer2_idx == i:
            reviewer2_idx = (reviewer2_idx + 1) % n
        
        assignments[student.email] = [
            students[reviewer1_idx].email,
            students[reviewer2_idx].email
        ]
    
    return assignments

def generate_comprehensive_table(students: List[Student]) -> str:
    """Generate a comprehensive table with all labs and all students"""
    
    # Create comprehensive table
    table = "# Comprehensive Peer Review Assignments (Labs 1-7)\n\n"
    
    # Header row with all labs
    header = "| Student | Email |"
    separator = "|---------|-------|"
    
    for lab_num in range(1, 8):
        header += f" Lab {lab_num} |"
        separator += "--------|"
    
    table += header + "\n"
    table += separator + "\n"
    
    # Data rows - each student sees who they need to review
    for i, student in enumerate(students):
        row = f"| {student.full_name} | {student.email} |"
        
        for lab_num in range(1, 8):
            # Calculate which students this student needs to review
            # Each student reviews the next 2 students in the list
            offset = (lab_num - 1) * 2  # Different offset for each lab
            review1_idx = (i + 1 + offset) % len(students)
            review2_idx = (i + 2 + offset) % len(students)
            
            # Skip self-review
            if review1_idx == i:
                review1_idx = (review1_idx + 1) % len(students)
            if review2_idx == i:
                review2_idx = (review2_idx + 1) % len(students)
            
            review1_name = students[review1_idx].full_name
            review2_name = students[review2_idx].full_name
            
            row += f" {review1_name}, {review2_name} |"
        
        table += row + "\n"
    
    return table

def export_comprehensive_csv(students: List[Student], filename: str = "comprehensive_peer_review_assignments.csv"):
    """Export comprehensive assignments to CSV file"""
    
    with open(filename, 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.writer(csvfile)
        
        # Header row
        header = ['Student Name', 'Student Email']
        for lab_num in range(1, 8):
            header.extend([f'Lab {lab_num} Review 1', f'Lab {lab_num} Review 2'])
        writer.writerow(header)
        
        # Data rows - each student sees who they need to review
        for i, student in enumerate(students):
            row = [student.full_name, student.email]
            
            for lab_num in range(1, 8):
                # Calculate which students this student needs to review
                offset = (lab_num - 1) * 2  # Different offset for each lab
                review1_idx = (i + 1 + offset) % len(students)
                review2_idx = (i + 2 + offset) % len(students)
                
                # Skip self-review
                if review1_idx == i:
                    review1_idx = (review1_idx + 1) % len(students)
                if review2_idx == i:
                    review2_idx = (review2_idx + 1) % len(students)
                
                review1_name = students[review1_idx].full_name
                review2_name = students[review2_idx].full_name
                
                row.extend([review1_name, review2_name])
            
            writer.writerow(row)
    
    print(f"Comprehensive assignments exported to {filename}")

def load_students_from_csv(filename: str) -> List[Student]:
    """Load student list from participants.csv file"""
    students = []
    
    with open(filename, 'r', encoding='utf-8') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            # Skip empty rows or rows without email
            if not row.get('Email address', '').strip():
                continue
                
            # Handle quoted column names and strip quotes
            first_name = row.get('First name', '').strip().strip('"')
            last_name = row.get('Last name', '').strip().strip('"')
            email = row.get('Email address', '').strip().strip('"')
            groups = row.get('Groups', '').strip().strip('"')
            
            student = Student(
                first_name=first_name,
                last_name=last_name,
                email=email,
                groups=groups
            )
            students.append(student)
    
    return students

def main():
    """Main function to run the peer review assignment"""
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: python peer_review_assigner.py <participants.csv>")
        print("Example: python peer_review_assigner.py participants.csv")
        sys.exit(1)
    
    participants_file = sys.argv[1]
    
    try:
        # Load students
        students = load_students_from_csv(participants_file)
        print(f"Loaded {len(students)} students from {participants_file}")
        
        # Generate comprehensive table
        print("\n🎯 Generating comprehensive assignments for all labs (1-7)...")
        
        comprehensive_table = generate_comprehensive_table(students)
        print("\n" + comprehensive_table)
        
        # Export comprehensive CSV
        export_comprehensive_csv(students)
        
        # Save comprehensive markdown
        comprehensive_file = "comprehensive_peer_review_assignments.md"
        with open(comprehensive_file, 'w', encoding='utf-8') as f:
            f.write(comprehensive_table)
        print(f"\nComprehensive assignments saved to {comprehensive_file}")
        
    except FileNotFoundError:
        print(f"Error: Could not find {participants_file}")
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main() 