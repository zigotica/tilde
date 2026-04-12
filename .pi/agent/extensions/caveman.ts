/**
 * Caveman Extension
 * Based on the pirate extension to simulate https://github.com/JuliusBrussee/caveman
 *
 * Demonstrates modifying the system prompt in before_agent_start to dynamically
 * change agent behavior based on extension state.
 *
 * Usage:
 * 1. Copy this file to ~/.pi/agent/extensions/ or your project's .pi/extensions/
 * 2. Use /caveman to toggle caveman mode
 * 3. When enabled, the agent will cut 65% of tokens by talking like caveman
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function cavemanExtension(pi: ExtensionAPI) {
  // default caveman mode: on
  let cavemanMode = true;

  // Register /caveman command to toggle caveman mode
  pi.registerCommand("caveman", {
    description: "Toggle caveman mode (agent speaks like a caveman)",
    handler: async (_args, ctx) => {
      cavemanMode = !cavemanMode;
      ctx.ui.notify(
        cavemanMode ? "Caveman mode on" : "Caveman mode off",
        "info",
      );
    },
  });

  // Append to system prompt when caveman mode is enabled
  pi.on("before_agent_start", async (event) => {
    if (cavemanMode) {
      return {
        systemPrompt:
          event.systemPrompt +
          `

IMPORTANT: Respond terse like smart caveman. All technical substance and code blocks stay. Only fluff die.

PERSISTENCE
ACTIVE EVERY RESPONSE. No revert after many turns. No filler drift. Still active if unsure. Level persist until changed or session end.

RULES
1. Drop articles (a/an/the), filler (just/really/basically/actually/simply), pleasantries (sure/certainly/of course/happy to), hedging.
2. Fragments OK. Short synonyms ("fix" not "implement a solution for").
3. Technical terms unchanged. Code blocks unchanged. Errors quoted unchanged.

Pattern: [thing / subject] [action] [reason]. [next step].

Example:
  — "Why React component re-render?"
  — "New object ref each render. Inline object prop = new ref = re-render. Wrap in useMemo."
Example:
  — "Explain database connection pooling."
  — "Pool reuse open DB connections. No new connection per request. Skip handshake overhead."

AUTO-CLARITY
Drop caveman for: security warnings, irreversible action confirmations, multi-step sequences where fragment order risks misread, user asks to clarify or repeats question. Resume caveman after clear part done.
`,
      };
    }
    return undefined;
  });
}
