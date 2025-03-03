def prepStats(apps, vacs, assigned, prio, iteration):
    d3 = apps.merge(assigned[['applicant_id', 'ass_priority_profile']], on='applicant_id', how='left')
    d3['ass_priority_profile'].fillna(0, inplace=True)
    d3 = d3[d3['ass_priority_profile'] >= d3['priority_profile']]
    d3 = d3.groupby(['program_id', 'quota_id', 'priority_profile']).size().reset_index(name='n_considered')
    
    tot_apps = apps.groupby(['program_id', 'quota_id']).size().reset_index(name='total_applicants')
    
    pp = prio.merge(assigned.groupby(['program_id', 'quota_id', 'priority_profile']).size().reset_index(name='assigned'), on=['program_id', 'quota_id', 'priority_profile'], how='left')
    pp = pp.merge(tot_apps, on=['program_id', 'quota_id'], how='left')
    pp = pp.merge(d3, on=['program_id', 'quota_id', 'priority_profile'], how='left')
    pp.fillna(0, inplace=True)
    pp['cum_ass'] = pp.groupby(['program_id', 'quota_id'])['assigned'].cumsum()
    pp = pp.merge(vacs.groupby(['program_id', 'quota_id']).agg(seats=('seat_order', 'max')), on=['program_id', 'quota_id'], how='left')
    pp.fillna(0, inplace=True)
    pp['iter'] = iteration
    pp.sort_values(by=['iter', 'program_id', 'quota_id', -pp['priority_profile'].astype(int)], inplace=True)
    pp['assigned'] = pp.groupby(['iter', 'program_id', 'quota_id'])['cum_ass'].shift().fillna(0)
    pp['assigned'] = pp['cum_ass'] - pp['assigned']
    pp['cum_ass'] -= pp['assigned']
    pp['total_seats'] = pp['seats']
    pp['seats'] -= pp['cum_ass']
    return pp
