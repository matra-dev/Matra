/// Sync status for UI indicator
enum SyncStatus {
  synced,    // All changes synced with backend
  syncing,   // Currently syncing
  pending,   // Changes queued, waiting for network
  error,     // Sync failed, will retry
}
