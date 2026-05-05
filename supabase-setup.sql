-- ============================================================
-- PICKLE YARD MONEYBALL THROWDOWN — Supabase Schema
-- Run this in your Supabase SQL Editor (Dashboard > SQL Editor)
-- ============================================================

-- Teams table
CREATE TABLE IF NOT EXISTS tournament_teams (
  id TEXT PRIMARY KEY,
  pool TEXT NOT NULL CHECK (pool IN ('A', 'B')),
  name TEXT NOT NULL,
  p1_name TEXT NOT NULL,
  p2_name TEXT NOT NULL,
  p1_dupr TEXT DEFAULT '',
  p2_dupr TEXT DEFAULT '',
  p1_email TEXT DEFAULT '',
  p2_email TEXT DEFAULT '',
  p1_phone TEXT DEFAULT '',
  p2_phone TEXT DEFAULT '',
  paid BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Matches table
CREATE TABLE IF NOT EXISTS tournament_matches (
  id TEXT PRIMARY KEY,
  phase TEXT NOT NULL CHECK (phase IN ('pool', 'playoff')),
  pool TEXT,
  round TEXT NOT NULL,
  court INTEGER,
  home_team_id TEXT REFERENCES tournament_teams(id) ON DELETE SET NULL,
  away_team_id TEXT REFERENCES tournament_teams(id) ON DELETE SET NULL,
  home_score INTEGER,
  away_score INTEGER,
  label TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tournament settings (admin PIN, event state, etc.)
CREATE TABLE IF NOT EXISTS tournament_settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert default admin PIN
INSERT INTO tournament_settings (key, value) VALUES ('admin_pin', '1987')
ON CONFLICT (key) DO NOTHING;

-- Insert event status
INSERT INTO tournament_settings (key, value) VALUES ('event_status', 'registration')
ON CONFLICT (key) DO NOTHING;

-- Enable Row Level Security
ALTER TABLE tournament_teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE tournament_matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE tournament_settings ENABLE ROW LEVEL SECURITY;

-- RLS Policies: Everyone can READ (public tournament data)
CREATE POLICY "Public read teams" ON tournament_teams FOR SELECT USING (true);
CREATE POLICY "Public read matches" ON tournament_matches FOR SELECT USING (true);
CREATE POLICY "Public read settings" ON tournament_settings FOR SELECT USING (key != 'admin_pin');

-- RLS Policies: Anon can INSERT/UPDATE/DELETE (admin uses PIN check in app)
CREATE POLICY "Anon manage teams" ON tournament_teams FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Anon manage matches" ON tournament_matches FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Anon manage settings" ON tournament_settings FOR ALL USING (true) WITH CHECK (true);

-- Enable realtime for live updates
ALTER PUBLICATION supabase_realtime ADD TABLE tournament_teams;
ALTER PUBLICATION supabase_realtime ADD TABLE tournament_matches;

-- Function to auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
CREATE TRIGGER teams_updated_at BEFORE UPDATE ON tournament_teams
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER matches_updated_at BEFORE UPDATE ON tournament_matches
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER settings_updated_at BEFORE UPDATE ON tournament_settings
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
