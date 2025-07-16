-- Remove GitHub-related columns from task_attempts table
PRAGMA foreign_keys=off;

-- Create new table without GitHub columns
CREATE TABLE task_attempts_new (
    id TEXT PRIMARY KEY NOT NULL,
    task_id TEXT NOT NULL,
    worktree_path TEXT NOT NULL,
    branch TEXT NOT NULL,
    base_branch TEXT NOT NULL,
    merge_commit TEXT,
    executor TEXT,
    worktree_deleted BOOLEAN NOT NULL DEFAULT 0,
    setup_completed_at DATETIME,
    created_at DATETIME NOT NULL DEFAULT (datetime('now')),
    updated_at DATETIME NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE
);

-- Copy data from old table
INSERT INTO task_attempts_new (id, task_id, worktree_path, branch, base_branch, merge_commit, executor, worktree_deleted, setup_completed_at, created_at, updated_at)
SELECT id, task_id, worktree_path, branch, base_branch, merge_commit, executor, worktree_deleted, setup_completed_at, created_at, updated_at
FROM task_attempts;

-- Drop old table
DROP TABLE task_attempts;

-- Rename new table
ALTER TABLE task_attempts_new RENAME TO task_attempts;

-- Recreate indexes
CREATE INDEX idx_task_attempts_task_id ON task_attempts(task_id);
CREATE INDEX idx_task_attempts_created_at ON task_attempts(created_at);
CREATE INDEX idx_task_attempts_worktree_deleted ON task_attempts(worktree_deleted);

PRAGMA foreign_keys=on;