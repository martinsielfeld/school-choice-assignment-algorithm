import numpy as np
from SyncRNG import SyncRNG

def lotteryNum(apps, type='py&r', breaktype='application', iterat=1, seed=None):

    if 'lottery_number' not in apps.columns:
        apps['lottery_number'] = np.nan

    if type not in ['py&r', 'local']:
        raise ValueError('Wrong type for lottery numbers')

    if iterat == 1 and not apps['lottery_number'].isna().any():
        print('    Random numbers detected')
    else:
        print('    Creating random numbers')
        if type == 'py&r':
            v = list(range(1, len(apps) + 1))
            s = SyncRNG(seed=seed)
            apps['lottery_number'] = s.shuffle(v)
        elif type == 'local':
            np.random.seed(seed)
            max_digits = len(str(len(apps)))
            apps['lottery_number'] = np.random.choice(10**max_digits - 1, len(apps), replace=False, dtype=np.int64)

        apps['lottery_number'] /= 10**apps['lottery_number'].astype(str).str.len().max()

        if breaktype == 'applicant':
            apps['lottery_number'] = apps.groupby('applicant_id')['lottery_number'].transform('first')

    apps['score'] = apps['priority_profile'] + apps['lottery_number']
    return apps
