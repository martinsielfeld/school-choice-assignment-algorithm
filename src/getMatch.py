import pandas as pd

def getMatch(apps, vacs, reg_cap_id=None, trans_cap=False):
    print("    Starting assignment algorithm")

    # Handling transfer capacity and re-assigning quotas
    if reg_cap_id > 1 and trans_cap:
        a = apps[apps['quota_id'] != reg_cap_id].copy()
        a['quota_id'] = reg_cap_id
        apps = pd.concat([apps, a], ignore_index=True)
        del a  # explicitly delete to free memory
    
    ## Prep ids:
    vacs['composite_key'] = vacs['program_id'].astype(int).astype(str) + '-' + vacs['seat_order'].astype(int).astype(str) + '-' + vacs['quota_id'].astype(int).astype(str)

    # Sorting and setting order
    apps = apps.sort_values(by=['applicant_id', 'ranking', 'quota_id'])
    apps['quota_order'] = apps.groupby(['applicant_id', 'ranking']).cumcount() + 1
    apps['order'] = apps.groupby('applicant_id').cumcount() + 1

    assigned = pd.DataFrame(columns=['applicant_id','ranking'])

    while not apps.empty:
        # Filtering applications to process
        a = apps[(apps['order'] == 1)]
        a = a[(~a['applicant_id'].isin(assigned['applicant_id']))]

        # Appending to assigned
        assigned = pd.concat([assigned, a], ignore_index=True)
        assigned.sort_values(by=['program_id', 'quota_id', 'score'], ascending=[True, True, False], inplace=True)
        assigned['seat_order'] = assigned.groupby(['program_id', 'quota_id']).cumcount() + 1
        assigned['composite_key'] = assigned['program_id'].astype(int).astype(str) + '-' + assigned['seat_order'].astype(int).astype(str) + '-' + assigned['quota_id'].astype(int).astype(str)
        assigned = assigned[assigned['composite_key'].isin(vacs['composite_key'])]
        assigned.drop(columns='composite_key', inplace=True)
        assigned['composite_key'] = assigned['applicant_id'].astype(int).astype(str) + '-' + assigned['order'].astype(int).astype(str)

        # Dropping processed apps and adjusting order
        apps['composite_key'] = apps['applicant_id'].astype(int).astype(str) + '-' + apps['order'].astype(int).astype(str)
        apps = apps[~apps['composite_key'].isin(assigned['composite_key'])]
        apps = apps[apps['order'] > 1]
        apps.sort_values(by=['applicant_id', 'order', 'quota_id'], inplace=True)
        
        if apps.empty:
             break
             
        apps['order'] = apps.groupby('applicant_id').cumcount() + 1
        apps.drop(columns='composite_key', inplace=True)
        assigned.drop(columns='composite_key', inplace=True)

    return assigned

