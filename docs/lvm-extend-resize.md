# Runbook: Extend an LVM Volume

## Safety first
- Take a backup or snapshot before any storage change.
- Confirm the exact device and mount point before you run anything.
- Extending is safe on mounted ext4 and XFS. Shrinking is risky and not covered here.

## 1. Inspect
```
lsblk
sudo pvs
sudo vgs
sudo lvs
df -h
```
Check that the volume group (VG) has free space (the `VFree` column in `vgs`).

## 2. If the VG has free space
```
sudo lvextend -r -L +5G /dev/<vg>/<lv>
```
The `-r` flag also resizes the filesystem.

## 3. If the VG is full, add a disk
```
sudo pvcreate /dev/<newdisk>
sudo vgextend <vg> /dev/<newdisk>
sudo lvextend -r -L +5G /dev/<vg>/<lv>
```

## 4. Resize the filesystem manually (if you did not use -r)
```
sudo resize2fs /dev/<vg>/<lv>      # ext4
sudo xfs_growfs <mountpoint>       # XFS
```

## 5. Verify
```
df -h
sudo lvs
```

## Common problems
- "Insufficient free space": add a physical volume (step 3).
- Volume grew but `df` is unchanged: the filesystem was not resized (step 4).
- Wrong device: stop, re-check with `lsblk` before running any command.
