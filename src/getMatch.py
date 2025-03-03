import pandas as pd

def getMatch(apps, vacs, reg_cap_id=None, trans_cap=False):
    print("\n        Starting DA algorithm")
    
    # Handling transfer capacity and re-assigning quotas
    if reg_cap_id is not None and reg_cap_id > 1 and trans_cap:
        a = apps[apps['quota_id'] != reg_cap_id].copy()
        a['quota_id'] = reg_cap_id
        apps = pd.concat([apps, a])
        del a  # explicitly delete to free memory

    # Sorting and setting order
    apps.sort_values(by=['applicant_id', 'ranking', 'quota_id'], inplace=True)
    apps['quota_order'] = apps.groupby(['applicant_id', 'ranking']).cumcount() + 1
    apps['order'] = apps.groupby('applicant_id').cumcount() + 1

    assigned = pd.DataFrame(columns=['applicant_id'])

    while not apps.empty:
        # Filtering applications to process
        a = apps[apps['order'] == 1]
        a = a[~a['applicant_id'].isin(assigned['applicant_id'])]

        # Appending to assigned
        assigned = pd.concat([assigned, a])
        assigned.sort_values(by=['program_id', 'quota_id', 'score'], ascending=[True, True, False], na_position='last', inplace=True)
        assigned['seat_order'] = assigned.groupby(['program_id', 'quota_id']).cumcount() + 1
        
        # Filtering assigned based on vacancies
        assigned = assigned[assigned.apply(lambda x: f"{x['program_id']}-{x['seat_order']}-{x['quota_id']}" in 
                                           vacs.apply(lambda y: f"{y['program_id']}-{y['seat_order']}-{y['quota_id']}", axis=1).values, axis=1)]
        
        # Dropping processed apps and adjusting order
        apps = apps[~apps['applicant_id'].isin(assigned['applicant_id'])]
        apps = apps[apps['order'] > 1]
        apps['order'] = apps.groupby('applicant_id').cumcount() + 1

        if apps.empty:
            break

    return assigned

