-- Remove GitHub PR tracking fields from task_attempts table
-- SQLite doesn't support DROP COLUMN directly, so we need to recreate the table

-- Create a new table without the GitHub fields
CREATE TABLE task_attempts_new (
    id TEXT PRIMARY KEY NOT NULL,
    task_id TEXT NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    worktree_path TEXT NOT NULL,
    branch TEXT NOT NULL,
    base_branch TEXT NOT NULL DEFAULT 'main',
    merge_commit TEXT,
    executor TEXT,
    worktree_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    setup_completed_at DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Copy data from the old table to the new table (excluding GitHub fields)
INSERT INTO task_attempts_new (
    id, task_id, worktree_path, branch, base_branch, 
    merge_commit, executor, worktree_deleted, setup_completed_at,
    created_at, updated_at
)
SELECT 
    id, task_id, worktree_path, branch, base_branch,
    merge_commit, executor, worktree_deleted, setup_completed_at,
    created_at, updated_at
FROM task_attempts;

-- Drop the old table
DROP TABLE task_attempts;

-- Rename the new table to the original name
ALTER TABLE task_attempts_new RENAME TO task_attempts;

-- Recreate indexes
CREATE INDEX idx_task_attempts_task_id ON task_attempts(task_id);
CREATE INDEX idx_task_attempts_created_at ON task_attempts(created_at);