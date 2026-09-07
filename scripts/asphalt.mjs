// Run from any directory: node scripts/asphalt.mjs sync cloud
// Requires Node.js 20.12+; reads the API key locally without printing it.
import { readFileSync, existsSync } from "node:fs";
import { parseEnv } from "node:util";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import { join } from "node:path";

const root = fileURLToPath(new URL("../", import.meta.url));
const args = process.argv.slice(2);
const envPath = join(root, ".env");
const local = existsSync(envPath) ? parseEnv(readFileSync(envPath, "utf8")) : {};
const env = { ...process.env };
if (local.ASPHALT_API_KEY) env.ASPHALT_API_KEY = local.ASPHALT_API_KEY;

if (args[0] === "sync" && !existsSync(join(root, "asphalt.toml"))) {
  console.error("Create asphalt.toml from asphalt.example.toml and set your Roblox creator type/ID first.");
  process.exit(1);
}
if ((args[0] === "upload" || (args[0] === "sync" && !args.includes("studio") && !args.includes("debug"))) && !env.ASPHALT_API_KEY) {
  console.error("Set ASPHALT_API_KEY in .env before uploading.");
  process.exit(1);
}
const result = spawnSync(process.platform === "win32" ? "asphalt.exe" : "asphalt", args.length ? args : ["--help"], {
  cwd: root, env, stdio: "inherit", shell: false,
});
if (result.error) {
  console.error("Could not launch Asphalt. Run rokit install and check that Rokit's bin directory is on PATH.");
  process.exit(1);
}
process.exit(result.status ?? 1);
