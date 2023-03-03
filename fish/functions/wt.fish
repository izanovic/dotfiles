function read_confirm
  while true
    read -l -P 'Would you like to create a new branch [y/N] ' confirm

    switch $confirm
      case Y y
        return 0
      case '' N n
        return 1
    end
  end
end

function wt
    set -lx dir (git worktree list | awk '{print $1; exit}');
    set -lx branch 'feature/MOFE-'$argv;
    if count $argv > /dev/null
        if git rev-parse --verify $branch
            cd $dir'/'$branch || git worktree add $dir'/'$branch $branch && cd $dir'/'$branch;
        else if read_confirm
            git worktree add -b $branch $dir'/'$branch && cd $dir'/'$branch;
        end
    else
        cd $dir;
    end
end

