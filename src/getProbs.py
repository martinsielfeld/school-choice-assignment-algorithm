def getProbs(ratex=None):
    ratex['ratex'] = ratex['seats'] / ratex['n_considered']
    ratex.loc[ratex['seats'] == 0, 'ratex'] = 0
    ratex.loc[(ratex['n_considered'] == 0) & (ratex['seats'] > 0), 'ratex'] = 1
    ratex.loc[ratex['ratex'] > 1, 'ratex'] = 1
    return ratex
