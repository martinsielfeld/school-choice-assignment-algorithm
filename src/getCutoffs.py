import pandas as pd

def getCutoffs(apps=None, vacs=None, assigned=None, cutoffs=None, iterat=None, hard_quota=False):
    if not hard_quota:
        apps['score'] = apps['priority_profile'] + apps['lottery_number']
        apps = apps.merge(assigned[['applicant_id', 'program_id', 'assigned']], on=['applicant_id', 'program_id'], how='left')
        apps['assigned'].fillna(0, inplace=True)
        apps = apps.sort_values(by=['program_id', -apps['score']])
        uc = apps[apps['assigned'] == 1].groupby('program_id').agg(upper_cutoff=('score', 'min'))
        lc = apps[apps['assigned'] == 0].groupby('program_id').agg(lower_cutoff=('score', 'max'))
        vacs = vacs[['program_id']].drop_duplicates()
        vacs = vacs.merge(uc, on='program_id', how='left').merge(lc, on='program_id', how='left')
        vacs['not_filled'] = vacs['upper_cutoff'].isna()
        vacs.fillna(1, inplace=True)
        vacs['iter'] = iterat
    else:
        # Similar process as above but considering quotas
        # Please adjust as needed for your specific quota-related logic
        pass
    cutoffs = pd.concat([cutoffs, vacs], ignore_index=True)
    return cutoffs
