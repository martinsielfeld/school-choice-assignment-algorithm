import os
import pandas as pd

# Settings
pd.options.mode.chained_assignment = None  # to avoid setting with copy warning

# Set working directory
user = os.getlogin()
if user == 'mds237':
    mainFolder = 'C:/Users/mds237/Desktop/Yale/Codes/school-choice-assignment-algorithm'
else:
    mainFolder = ''  # Add folder to data folder

# Install and load packages
# In Python, you typically install packages via pip in the command line, not in the script itself
# import necessary libraries already assumed installed

# Load data
files = ['A1', 'B1', 'C1', 'F1']  # 1 = round 1; 2 = round 2
data = {}
for i in files:
    data[i] = pd.read_csv(f'{mainFolder}/data/source/{i}.csv', encoding='utf-8',decimal=',',sep=';')

# General edits
# Program ID
data['A1'].sort_values(by=['rbd', 'cod_nivel', 'cod_curso'], inplace=True)
data['A1']['program_id'] = range(1, len(data['A1']) + 1)

# Crosswalk
crosswalk = data['A1'][['rbd', 'cod_curso', 'program_id']]

# Quotas
data['A1'] = data['A1'][['rbd', 'cod_nivel', 'program_id', 'vacantes_pie', 'vacantes_alta_exigencia_r',
                         'vacantes_prioritarios', 'vacantes_regular', 'vacantes']]
data['A1'].columns = ['school_id', 'grade_id', 'program_id', 'quota_1', 'quota_2', 'quota_3', 'regular_vacancies', 'total_vacancies']

# Applications
applications = pd.merge(data['C1'], data['B1'], on=['mrun', 'cod_nivel'])
applications = pd.merge(applications, crosswalk, on=['rbd', 'cod_curso'])

max_digits = applications['loteria_original'].astype(str).apply(len).max()
applications['loteria_original'] = applications['loteria_original'] / (10 ** max_digits)
applications.sort_values(by=['cod_nivel', 'mrun', 'preferencia_postulante'],ascending=[True, False, False],inplace=True)
applications['priority_profile'] = pd.cut(applications['preferencia_postulante'], bins=[0,1,2,3,4], labels=[4,3,2,1])

# Example data for algorithm 1
programs1 = data['A1'].copy()
programs1['regular_vacancies'] = programs1['total_vacancies']
programs1 = programs1[['school_id','grade_id','program_id','regular_vacancies']]

applications1 = applications.copy()
applications1['priority_profile'] = pd.NA
applications1.loc[applications1['prioridad_hermano'] == 1, 'priority_profile'] = 4
applications1.loc[applications1['priority_profile'].isna() & (applications1['prioridad_hijo_funcionario'] == 1), 'priority_profile'] = 3
applications1.loc[applications1['priority_profile'].isna() & applications1['prioridad_exalumno'].eq(1), 'priority_profile'] = 2
applications1.loc[applications1['priority_profile'].isna(), 'priority_profile'] = 1
applications1[['applicant_id', 'grade_id', 'ranking', 'lottery_number']] = applications1[['mrun','cod_nivel','preferencia_postulante','loteria_original']]
applications1 = applications1[['applicant_id','grade_id','program_id','ranking','priority_profile','lottery_number']]

applications1.to_csv(f'{mainFolder}/data/example_1/applications_py.csv', index=False)
programs1.to_csv(f'{mainFolder}/data/example_1/vacancies_py.csv', index=False)

# Clean up
del data
