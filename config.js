// Public settings for the shared leaderboard.
// Both values are safe to publish: the anon key only allows what the
// database rules in supabase/schema.sql allow. Never put the
// service_role key or any private key in this file.
window.SERVER_DOWN_CONFIG = {
  supabaseUrl: "https://YOUR-PROJECT.supabase.co",
  supabaseAnonKey: "YOUR-ANON-KEY"
};
