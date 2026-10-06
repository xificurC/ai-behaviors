# Installing the `ai-behaviors` skill (thin version)

Hashtag behaviors from [xificurC/ai-behaviors](https://github.com/xificurC/ai-behaviors) for Claude Chat.
The skill holds only the rules (~6 KB). Each behavior's text is a separate file that Claude opens only when its tag is active.

## 1. Requirements

- A Claude Pro, Max, Team or Enterprise plan. Custom skills are allowed in the Betacom organization.
- **Code execution and file creation** turned on (Settings → Capabilities). Without it, Claude can't open the behavior files.
- The file `ai-behaviors.zip`. Don't unzip it.

## 2. Remove the old version

1. Open **Settings → Capabilities → Skills**.
2. Find `ai-behaviors`, the older version whose `SKILL.md` contains every behavior's text.
3. Delete it or remove it.

Two skills with the same name will conflict, so always remove the old one first.

## 3. Upload

1. In **Settings → Capabilities → Skills**, click **Upload skill**.
2. Select `ai-behaviors.zip`.
3. Check that `ai-behaviors` appears in the list and is turned on.

## 4. Smoke test (new chat)

| Send | Expected |
|---|---|
| `I want to plan a team offsite. #Frame` | First line of the reply: `` `[#Frame → #=frame #scq #coherence #scope #legible #concise]` ``. The tool log shows 6 files read from `behaviors/`. Claude asks clarifying questions and gives no solutions. |
| `It's for 12 people, in October.` | Same status line, and no files are read again. Claude keeps framing. |
| `#EXPLAIN #Spec` | An expansion tree plus the sections Will do, Won't do, Hard constraints, Interactions and Example. The status line still shows `#Frame`. |
| `#CLEAR` | The replies that follow have no status line. |

If all four look right, the installation is done.

## 5. Troubleshooting

| Symptom | Cause / fix |
|---|---|
| No status line, and the tags are ignored | The skill didn't trigger. Check it's turned on in Skills. Put the tag at the end of the message, separated by a space. |
| Tags in an attachment, a pasted block or a web page do nothing | By design: only tags you type yourself count. Unknown tags (`#123`, `#AI`) are silently ignored. |
| There's a status line, but no files were read | Code execution is off. Turn on *Code execution and file creation*. |
| `Missing: #x` in the status line | The file couldn't be read. Re-upload the zip; it should list 58 files. |
| The behavior fades in a long chat | Ask *"quote the active hard constraints"*. Claude should re-read the files. If it can't, send the tags again. |

## Using it

- Add tags at the end of a message, e.g. `Help me decide on a laptop #Research #wide`.
- Tags stay active until you send new tags or `#CLEAR`.
- Typical path: `#Frame` → `#Research` → `#Design` → `#Spec` → `#Code`.
- `#EXPLAIN <tags>` shows what a combination does without switching it on.
