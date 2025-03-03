import pandas as pd

def expandPriorities(prg_id=None, quo=None, prio_id=None):
    grid = pd.DataFrame({
        "program_id": prg_id,
        "quota_id": quo,
        "priority_profile": prio_id
    })
    grid = pd.MultiIndex.from_product(grid.values.T, names=grid.columns).to_frame(index=False)
    grid = grid.sort_values(by=["program_id", "quota_id", -grid["priority_profile"].astype(int)])
    return grid
