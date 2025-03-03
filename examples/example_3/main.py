import sys
from pathlib import Path
import pandas as pd

# Adjust the path to include the src directory
current_dir = Path(__name__).resolve().parent
current_dir = str(current_dir) + '\\src'
sys.path.append(current_dir)

# Import the necessary module
from baseSAA import baseSAA

# Load data
vacancies = pd.read_csv('data/example_3/vacancies_r.csv')
applications = pd.read_csv('data/example_3/applications_r.csv')

# Prep data for different mechanisms
soft_boston = applications[['applicant_id', 'grade_id', 'program_id', 'ranking', 'quota_id', 'priority_profile_ori']].rename(columns={'priority_profile_ori': 'priority_profile'})
base_da = applications[['applicant_id', 'grade_id', 'program_id', 'ranking', 'quota_id', 'priority_profile_edi']].rename(columns={'priority_profile_edi': 'priority_profile'})

# Execute the assignment algorithms
results_1 = baseSAA(apps=soft_boston, vacs=vacancies, get_cutoffs=False, transfer_capacity=False, iters=1)
results_2 = baseSAA(apps=base_da, vacs=vacancies, get_cutoffs=False, transfer_capacity=False, iters=1)

# Results can be further analyzed or saved as needed

