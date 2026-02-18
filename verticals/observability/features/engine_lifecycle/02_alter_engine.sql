-- Engine Lifecycle Demo (Cloud only): Alter engine settings
-- When connected to Firebolt Cloud, you can change auto-vacuum and other settings.
-- On Core, this is shown as reference only.

-- Turn off auto-vacuum to dedicate all resources to queries (Cloud)
-- ALTER ENGINE my_engine SET AUTO_VACUUM = OFF;

-- Turn on auto-vacuum for better read performance (Cloud)
-- ALTER ENGINE my_engine SET AUTO_VACUUM = ON;

-- Set idle timeout (auto-stop) via Firebolt Cloud UI, or when supported:
-- ALTER ENGINE my_engine SET AUTO_STOP = 30;
