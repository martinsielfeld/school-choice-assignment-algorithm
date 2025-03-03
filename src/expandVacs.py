import pandas as pd
import numpy as np
import re

def expandVacs(vacs):

    quota_columns = [col for col in vacs.columns if 'quota_' in col]
    if quota_columns:
        quota_columns_sorted = sorted(quota_columns, key=lambda x: int(re.sub(r'quota_', '', x)))
        quota_columns_sorted
    else:
        None

    # Ensure necessary columns are present
    if 'program_id' not in vacs.columns or 'regular_vacancies' not in vacs.columns:
        raise ValueError("Columns 'program_id' and 'regular_vacancies' are required.")
    
    # Sort the quota columns numerically based on the number following 'quota_'
    quota_columns_sorted = sorted(quota_columns, key=lambda x: int(x.split('_')[1]))
    
    # Using wide_to_long
    vacs_long = pd.wide_to_long(vacs, stubnames=['quota_', 'regular_'], 
                                i='program_id', j='quota_id', suffix='\w+').reset_index()
    vacs_long.rename(columns={'quota__vacancies': 'vacancies'}, inplace=True)

    vacs_long['vacancies'] = np.where(~pd.isna(vacs_long['quota_']), vacs_long['quota_'], vacs_long['regular_'])
    max_quota_id = pd.to_numeric(vacs_long['quota_id'], errors='coerce').max()
    new_quota_id = max_quota_id + 1
    vacs_long['quota_id'] = vacs_long['quota_id'].replace('vacancies', new_quota_id)

    # Filter out rows where vacancies are zero
    vacs_long = vacs_long[vacs_long['vacancies'] > 0]

    # Generate a new 'seat_order' column for each group of 'program_id' and 'quota_id'
    vacs_long = vacs_long.loc[vacs_long.index.repeat(vacs_long['vacancies'])].reset_index(drop=True)
    vacs_long['seat_order'] = vacs_long.groupby(['program_id', 'quota_id']).cumcount() + 1

    # Sort the DataFrame by 'program_id', 'quota_id', and 'seat_order'
    vacs_long.sort_values(by=['program_id', 'quota_id', 'seat_order'], inplace=True)

    vacs_long = vacs_long[['program_id', 'quota_id', 'seat_order']]

    print(vacs_long.columns)
    print(vacs_long)

    return vacs_long
