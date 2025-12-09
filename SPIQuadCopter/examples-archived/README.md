# Examples (archived)

This folder contains notes about examples that were removed from the active
source tree to keep the repository focused. The original RTL and testbench
files for some examples (for example `src/led_blinker.sv` and
`src/led_blinker_tb.sv`) have been deleted from the working tree but remain in
git history.

If you need to restore an archived example from the repository history, use
these commands from the repository root:

```bash
# show commits that touched the file
git log --follow -- src/led_blinker.sv

# restore the file from a commit (replace <commit> with the commit hash)
git checkout <commit> -- src/led_blinker.sv

# or restore from the branch where it existed, e.g.
# git checkout origin/master -- src/led_blinker.sv

# After restoring, add/commit as needed
git add src/led_blinker.sv
git commit -m "Restore archived led_blinker example"
```

If you'd like, I can try to recover the last copy of the files and place them
here in `examples-archived/` (if git history is available in this environment).
