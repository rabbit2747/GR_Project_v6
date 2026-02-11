# Verification Report: ACTOR

## Summary
- Total verified: 247
- No issues: 167
- Minor issues: 32
- Major issues: 7
- Invalid relation types: 73 files

---

## Invalid Relation Types

### CRITICAL: The following relation types are NOT in the valid set and must be corrected.

Valid types: is_a, part_of, instance_of, abstracts, causes, enables, prevents, requires, conflicts_with, alternative_to, precedes, supersedes, applies_to, effective_against, implements, contradicts, disputes, refines

---

### APT Files with Invalid Relation Types

#### actor_apt_grizstep_001.yaml (Grizzly Steppe)
- relations[0]: type "consists_of" is INVALID --> should be "part_of" (reversed direction) or keep as-is if the ontology adds consists_of; conceptually Grizzly Steppe consists of Cozy Bear, so the relation should be inverted: Cozy Bear "part_of" Grizzly Steppe

#### actor_apt_gruelarc_001.yaml (Gruesome Larch / APT28)
- relations[0]: type "consists_of" is INVALID --> should be "part_of" (with reversed direction, or re-express as Grizzly Steppe contains APT28)
- relations[1]: type "uses" is INVALID --> should be "enables" or remove (the description about sharing infrastructure doesn't match "uses" semantics accurately either)

#### actor_apt_hackteam_001.yaml (Hacking Team)
- relations[1]: type "targets" is INVALID --> should be "applies_to" or "enables" (the description about overlapping targets is not a real relation)

#### actor_apt_indizebr_001.yaml (Indigo Zebra)
- relations[0]: type "uses" is INVALID --> should be "enables" (sharing tooling/infrastructure patterns)
- relations[1]: type "targets" is INVALID --> should be "applies_to" or remove

#### actor_apt_inkysqui_001.yaml (Inky Squid)
- relations[0]: type "attributed_to" is INVALID --> should be "is_a" (Inky Squid is an alias for ScarCruft, so "is_a" or "instance_of" fits better)
- relations[1]: type "collaborates_with" is INVALID --> should be "enables" or remove

#### actor_apt_iranthre_001.yaml (Iran Threats)
- relations[0]: type "consists_of" is INVALID --> should use inverted "part_of" (MuddyWater part_of Iran Threats)
- relations[1]: type "consists_of" is INVALID --> same as above for OilRig
- relations[2]: type "consists_of" is INVALID --> same as above for Moses Staff

#### actor_apt_lazyscri_001.yaml (Lazy Scripter)
- relations[0]: type "targets" is INVALID --> should be "applies_to" or remove

#### actor_apt_lotublos_001.yaml (Lotus Blossom)
- relations[0]: type "attributed_to" is INVALID --> should be "enables" or "part_of" (describing shared Chinese state sponsor)
- relations[1]: type "targets" is INVALID --> should be "applies_to" or remove

#### actor_apt_luckmous_001.yaml (Lucky Mouse / APT27)
- relations[0]: type "collaborates_with" is INVALID --> should be "enables" (sharing tooling)
- relations[1]: type "uses" is INVALID --> should be "enables" or remove

#### actor_apt_lumimoth_001.yaml (Luminous Moth)
- relations[0]: type "collaborates_with" is INVALID --> should be "enables"
- relations[1]: type "uses" is INVALID --> should be "enables" or remove

#### actor_apt_menupass_001.yaml (MenuPass / APT10)
- relations[0]: type "collaborates_with" is INVALID --> should be "enables"

#### actor_apt_mirrorface_001.yaml (MirrorFace)
- relations[0]: type "attributed_to" is INVALID --> should be "part_of" (MirrorFace is linked to APT10)
- relations[1]: type "targets" is INVALID --> should be "applies_to" or remove

#### actor_apt_mosestaf_001.yaml (Moses Staff)
- relations[0]: type "attributed_to" is INVALID --> should be "part_of" (part of Iranian ecosystem)
- relations[1]: type "collaborates_with" is INVALID --> should be "enables"

#### actor_apt_mousboun_001.yaml
- relations[0]: type "collaborates_with" is INVALID --> should be "enables"

#### actor_apt_muddywater_001.yaml (MuddyWater)
- relations[0]: type "attributed_to" is INVALID --> should be "part_of" (part of Iranian threat ecosystem)
- relations[1]: type "collaborates_with" is INVALID --> should be "enables"

#### actor_apt_noblbaro_001.yaml (Noble Baron)
- relations[0]: type "attributed_to" is INVALID --> should be "is_a" (Noble Baron IS APT29/Cozy Bear)
- relations[1]: type "attributed_to" is INVALID --> should be "is_a" (DarkHalo IS the same actor)
- relations[2]: type "consists_of" is INVALID --> should be "part_of" with reversed direction

#### actor_apt_oceanlotus_001.yaml (OceanLotus)
- relations[0]: type "targets" is INVALID --> should be "applies_to" or remove
- relations[1]: type "targets" is INVALID --> should be "applies_to" or remove

#### actor_apt_oilrig_001.yaml (OilRig)
- relations[0]: type "attributed_to" is INVALID --> should be "part_of"
- relations[1]: type "collaborates_with" is INVALID --> should be "enables"

#### actor_apt_opecucbee_001.yaml
- relations[0]: type "attributed_to" is INVALID --> should be "part_of" or "is_a"
- relations[1]: type "uses" is INVALID --> should be "enables"

#### actor_apt_opjeru_001.yaml
- relations[0]: type "attributed_to" is INVALID --> should be "part_of" or "is_a"
- relations[1]: type "targets" is INVALID --> should be "applies_to"

#### actor_apt_oppoihan_001.yaml
- relations[0]: type "targets" is INVALID --> should be "applies_to"
- relations[1]: type "uses" is INVALID --> should be "enables"

#### actor_apt_optria_001.yaml
- relations[0]: type "targets" is INVALID --> should be "applies_to"
- relations[1]: type "targets" is INVALID --> should be "applies_to"

#### actor_apt_pitttige_001.yaml
- relations[0]: type "collaborates_with" is INVALID --> should be "enables"
- relations[1]: type "uses" is INVALID --> should be "enables"

#### actor_apt_powerpool_001.yaml (PowerPool)
- relations[0]: type "exploits" is INVALID --> should be "enables" (the description about shared PowerShell tooling doesn't match "exploits")

#### actor_apt_projsaur_001.yaml
- relations[0]: type "targets" is INVALID --> should be "applies_to"
- relations[1]: type "targets" is INVALID --> should be "applies_to"

#### actor_apt_purpbrav_001.yaml
- relations[0]: type "collaborates_with" is INVALID --> should be "enables"
- relations[1]: type "targets" is INVALID --> should be "applies_to"

#### actor_apt_redcurl_001.yaml
- relations[0]: type "targets" is INVALID --> should be "applies_to"
- relations[1]: type "uses" is INVALID --> should be "enables"

### Vendor Files with Invalid Relation Types

The following vendor files use "produces", "provides", "enhances", "depends_on", or "is_target_of" -- ALL are INVALID relation types:

#### Files using "produces" (INVALID --> should be "enables" or "implements"):
- actor_vendor_ahnlab_001.yaml
- actor_vendor_alienvault_001.yaml
- actor_vendor_amaztech_001.yaml
- actor_vendor_aquasec_001.yaml
- actor_vendor_auth0_001.yaml
- actor_vendor_beyondtrus_001.yaml
- actor_vendor_bitdefende_001.yaml
- actor_vendor_bitgo_001.yaml
- actor_vendor_bizone_001.yaml
- actor_vendor_blackberry_001.yaml
- actor_vendor_carblainc_001.yaml
- actor_vendor_clearsky_001.yaml
- actor_vendor_cloudflare_001.yaml (2 instances)
- actor_vendor_connectwis_001.yaml
- actor_vendor_cyberbit_001.yaml
- actor_vendor_cycognito_001.yaml
- actor_vendor_cycraft_001.yaml
- actor_vendor_darkcoders_001.yaml
- actor_vendor_deepseek_001.yaml
- actor_vendor_deepsight_001.yaml
- actor_vendor_dellinc_001.yaml
- actor_vendor_digicert_001.yaml
- actor_vendor_digininja_001.yaml
- actor_vendor_diginotar_001.yaml
- actor_vendor_digishad_001.yaml
- actor_vendor_digitrust_001.yaml
- actor_vendor_draytek_001.yaml
- actor_vendor_elevenlabs_001.yaml
- actor_vendor_exatrack_001.yaml
- actor_vendor_falfortea_001.yaml
- actor_vendor_fireeye_001.yaml (2 instances)
- actor_vendor_fornorsec_001.yaml
- actor_vendor_fortigard_001.yaml
- actor_vendor_fortiguard_001.yaml
- actor_vendor_foxglove_001.yaml
- actor_vendor_hackerone_001.yaml
- actor_vendor_helpsyst_001.yaml
- actor_vendor_huntlabs_001.yaml
- actor_vendor_jetbrains_001.yaml
- actor_vendor_joesecu_001.yaml
- actor_vendor_jumplabs_001.yaml
- actor_vendor_kasplab_001.yaml
- actor_vendor_mcafee_001.yaml
- actor_vendor_micrfocu_001.yaml
- actor_vendor_microsoft_001.yaml
- actor_vendor_msfsecint_001.yaml
- actor_vendor_netsarang_001.yaml
- actor_vendor_nextsyst_001.yaml
- actor_vendor_nibblesec_001.yaml
- actor_vendor_nirsoft_001.yaml
- actor_vendor_objesee_001.yaml
- actor_vendor_palaltnet_001.yaml (2 instances)
- actor_vendor_portswigge_001.yaml
- actor_vendor_proofpoint_001.yaml
- actor_vendor_purplesec_001.yaml
- actor_vendor_qianxin_001.yaml
- actor_vendor_reasonlabs_001.yaml
- actor_vendor_recofutu_001.yaml
- actor_vendor_redcana_001.yaml
- actor_vendor_redhat_001.yaml
- actor_vendor_rhiseclab_001.yaml
- actor_vendor_rosesecu_001.yaml
- actor_vendor_safebreach_001.yaml
- actor_vendor_safedete_001.yaml
- actor_vendor_sagiesec_001.yaml
- actor_vendor_trenmicr_001.yaml
- actor_vendor_withsecure_001.yaml

#### Files using "provides" (INVALID --> should be "enables"):
- actor_vendor_globsign_001.yaml
- actor_vendor_huntlabs_001.yaml
- actor_vendor_ironnet_001.yaml
- actor_vendor_kasplab_001.yaml
- actor_vendor_mcafee_001.yaml
- actor_vendor_microsoft_001.yaml
- actor_vendor_nowsecure_001.yaml
- actor_vendor_proofpoint_001.yaml
- actor_vendor_purplesec_001.yaml
- actor_vendor_qianxin_001.yaml
- actor_vendor_reaqta_001.yaml
- actor_vendor_reasonlabs_001.yaml
- actor_vendor_recofutu_001.yaml
- actor_vendor_redcana_001.yaml
- actor_vendor_redhlabs_001.yaml
- actor_vendor_reliaquest_001.yaml
- actor_vendor_revelab_001.yaml
- actor_vendor_safebreach_001.yaml

#### Files using "enhances" (INVALID --> should be "enables" or "refines"):
- actor_vendor_cardinalop_001.yaml
- actor_vendor_digishad_001.yaml
- actor_vendor_fortigard_001.yaml
- actor_vendor_fortiguard_001.yaml

#### Files using "depends_on" (INVALID --> should be "part_of" or "requires"):
- actor_vendor_securelist_001.yaml
- actor_vendor_securework_001.yaml
- actor_vendor_trenlabs_001.yaml
- actor_vendor_trmihile_001.yaml
- actor_vendor_withlabs_001.yaml

#### Files using "is_target_of" (INVALID --> should express differently):
- actor_vendor_netsarang_001.yaml

---

## Major Issues (Factual Errors)

### ACTOR-APT-STARBLIZ-001 - Star Blizzard (CRITICAL IDENTITY CONFUSION)
- **Issue**: The atom file describes Star Blizzard (SEABORGIUM/Callisto Group), which is attributed to **FSB Centre 18**. However, the atom ID `ACTOR-APT-STARBLIZ-001` is referenced by `actor_apt_badpilot_001.yaml` and `actor_apt_confcrew_001.yaml` as if it were **Seashell Blizzard (Sandworm)**, which is attributed to the **GRU (Unit 74455)**. These are two completely different Russian threat groups from different intelligence services.
- **Correction**: Either (a) create a separate atom for Seashell Blizzard/Sandworm (GRU Unit 74455) with a different ID (e.g., `ACTOR-APT-SEASBLIZ-001`) and update BadPilot/ConfCrew references to point there, OR (b) rename the existing Star Blizzard atom to Seashell Blizzard and create a new atom for Star Blizzard/SEABORGIUM. BadPilot is a subgroup of Seashell Blizzard/Sandworm, NOT Star Blizzard/SEABORGIUM.

### ACTOR-APT-NOBLBARO-001 - Noble Baron (DUPLICATE ENTITY)
- **Issue**: Noble Baron is described as "a designation associated with APT29/Cozy Bear/Midnight Blizzard." However, there is already a dedicated `ACTOR-APT-COZYBEAR-001` (Cozy Bear/APT29) AND `ACTOR-APT-DARKHALO-001` (DarkHalo/UNC2452). Noble Baron, Cozy Bear, and DarkHalo all refer to the same threat actor (APT29/SVR). Having three separate atoms for the same actor creates redundancy and confusion.
- **Correction**: Consider consolidating into a single canonical atom for APT29 (Cozy Bear) and making Noble Baron and DarkHalo aliases rather than separate atoms. If separate atoms are intentional for tracking different vendor naming conventions, the relation should be "is_a" (same entity) rather than "attributed_to".

### ACTOR-APT-SEALOTU-001 - Sea Lotus (DUPLICATE of OceanLotus)
- **Issue**: Sea Lotus (ACTOR-APT-SEALOTU-001) is a duplicate entry for the same Vietnamese APT group already documented as OceanLotus (ACTOR-APT-OCEANLOTUS-001). Both atoms list APT32, Canvas Cyclone, BISMUTH, and Cobalt Kitty as aliases and describe the same Vietnamese state-sponsored group.
- **Correction**: Merge into a single canonical atom or clearly define one as the canonical entry and make the other a pointer/alias reference.

### ACTOR-APT-INKYSQUI-001 - Inky Squid (DUPLICATE of ScarCruft)
- **Issue**: Inky Squid (ACTOR-APT-INKYSQUI-001) is a duplicate entry for the same North Korean APT group already documented as ScarCruft (ACTOR-APT-SCARCRUFT-001). Both list APT37, Reaper, Ricochet Chollima, and Group123 as aliases.
- **Correction**: Merge into a single canonical atom or clearly define one as the canonical entry.

### ACTOR-APT-GRUELARC-001 - Gruesome Larch / APT28 (Incorrect Relation)
- **Issue**: The relation `consists_of` targeting ACTOR-APT-GRIZSTEP-001 states "One of the two APT groups comprising the Grizzly Steppe designation." This relation is semantically inverted -- APT28 does not "consist of" Grizzly Steppe; rather, Grizzly Steppe consists of APT28 (and APT29). Additionally, the second relation using "uses" to link to BadPilot (ACTOR-APT-BADPILOT-001) is incorrect -- BadPilot is a subgroup of Seashell Blizzard (Sandworm/GRU Unit 74455), NOT of APT28 (GRU Unit 26165). These are different GRU units.
- **Correction**: (1) Change relation[0] to "part_of" Grizzly Steppe. (2) Remove or correct relation[1] -- BadPilot is not related to APT28/Gruesome Larch; it belongs to Seashell Blizzard/Sandworm.

### ACTOR-APT-GRIZSTEP-001 - Grizzly Steppe (Inverted Relation)
- **Issue**: The relation `consists_of` targeting ACTOR-APT-COZYBEAR-001 is semantically correct (Grizzly Steppe does consist of Cozy Bear), but "consists_of" is not a valid relation type.
- **Correction**: Invert to make Cozy Bear "part_of" Grizzly Steppe, or add "consists_of" to the valid relation type list if it's needed for the ontology.

### ACTOR-APT-HACKTEAM-001 - Hacking Team (Incorrect Relation Target)
- **Issue**: relation[1] states Hacking Team has "Overlapping surveillance targets with nation-state APT groups" with target ACTOR-APT-OCEANLOTUS-001. There is no established public intelligence linking Hacking Team's target set specifically to OceanLotus. Hacking Team sold tools to many governments but this specific relation to OceanLotus is not well-supported.
- **Correction**: Remove this relation or replace with a more accurate one, such as documenting that Hacking Team tools were found in use by various APT groups.

---

## Minor Issues

### ACTOR-APT-BENDBEAR-001 - Bendy Bear
- **Issue**: Relation `enables` targeting ACTOR-APT-BLACKTECH-001 with description "Bendy Bear activity is closely associated with and may be part of BlackTech operations" -- the semantics better fit "part_of" rather than "enables."
- **Correction**: Change relation type to "part_of" if Bendy Bear is considered a subset of BlackTech operations.

### ACTOR-APT-DARKHALO-001 - DarkHalo
- **Issue**: Relation `is_a` targeting ACTOR-APT-COZYBEAR-001 with description "DarkHalo is an activity designation that overlaps with APT29/Cozy Bear" -- this is semantically appropriate but represents a duplicate entity (see Major Issues above).

### ACTOR-APT-BEAGBOYZ-001 - Beagle Boyz
- **Issue**: The alias "APT38 Subset" is slightly misleading. Beagle Boyz is better characterized as overlapping with APT38 operations rather than being a strict subset. APT38 is itself a Mandiant designation that substantially overlaps with BlueNoroff (CrowdStrike: Stardust Chollima).
- **Correction**: Consider changing alias to "APT38 Overlap" or removing it.

### ACTOR-APT-CATAGROU-001 - Catalina Group
- **Issue**: The alias "Ajax Security Team" is a separate Iranian group from the early 2010s that may have evolved into or been absorbed by Charming Kitten operations, but the connection is debated. Some researchers treat Ajax Security Team as a distinct entity.
- **Correction**: Add a note that the Ajax Security Team connection is assessed with lower confidence.

### ACTOR-APT-DARKVISHNY-001 - DarkVishnya
- **Issue**: DarkVishnya is categorized as an APT (actor_apt_*) but the definition describes a financially motivated criminal operation, not a state-sponsored APT. The classification as "APT" may be misleading.
- **Correction**: Consider reclassifying as actor_crime_* to better reflect the financially motivated nature of the operation.

### ACTOR-APT-COSTARICTO-001 - CostaRicto
- **Issue**: Similarly to DarkVishnya, CostaRicto is a mercenary/hack-for-hire group, not a traditional APT. The "APT" prefix may be misleading.
- **Correction**: Consider reclassifying as actor_crime_* or creating an actor_mercenary_* category.

### ACTOR-APT-POWERPOOL-001 - PowerPool
- **Issue**: The sole relation uses invalid type "exploits" and incorrectly links to MuddyWater based only on "both groups heavily leverage PowerShell-based tooling." This is a weak connection -- many threat actors use PowerShell. PowerPool has no established operational relationship with MuddyWater.
- **Correction**: Remove this relation entirely as it implies a non-existent operational connection.

### ACTOR-APT-LOTUBLOS-001 - Lotus Blossom
- **Issue**: The alias "Thrip" is listed, but Thrip is a Symantec designation that was later merged into the Billbug cluster. While related, the Thrip-to-Lotus Blossom connection is still debated by some researchers who see them as potentially distinct.
- **Correction**: Note that the Thrip alias has moderate confidence.

### Multiple APT Files - Self-Referencing is_a Relations
- **Issue**: Many APT files (aridvipe, backdipl, bendbear, blacktech, blotquas, cactuspete, catagrou, copykitt, costaricto, cozybear, cuckoobees, darkhotel, darkhydrus, darkvishny, deputydog, etc.) have a relation `is_a` targeting themselves (e.g., `ACTOR-APT-ARIDVIPE-001` has `is_a` target `ACTOR-APT-ARIDVIPE-001`). A self-referencing `is_a` relation is semantically meaningless.
- **Correction**: Either remove these self-referencing relations or change the target to a category/classification atom (e.g., ACTOR-APT-CATEGORY-001).

### Multiple APT Files - Generic "enables" to ATK-INITIAL-SPEARPHISH-001
- **Issue**: Nearly all APT files have a relation `enables` targeting `ATK-INITIAL-SPEARPHISH-001` regardless of whether the actor actually uses spearphishing as a primary technique. For example, DarkVishnya (physical access) and BadPilot (internet-facing exploitation) have this relation despite their primary access vectors being non-phishing.
- **Correction**: Review each actor's actual primary initial access vector and adjust the relation target accordingly.

### ACTOR-APT-CONTINTE-001 - Contagious Interview
- **Issue**: The alias "Famous Chollima Subgroup" is debatable. While Contagious Interview operates within the broader DPRK ecosystem, it's more commonly associated with Lazarus Group's broader operations rather than specifically the "Famous Chollima" CrowdStrike designation. The relation `part_of` ACTOR-APT-FAMOCHOL-001 is appropriate, however.
- **Correction**: Consider removing "Famous Chollima Subgroup" as a direct alias and keeping the part_of relation.

### ACTOR-VENDOR-DIGINOTAR-001 - DigiNotar
- **Issue**: DigiNotar is classified as a vendor (actor_vendor_*) but is a defunct company that went bankrupt in 2011. It is more accurately a historical case study than an active vendor.
- **Correction**: Minor -- acceptable as historical vendor entry, but could note defunct status more prominently.

### ACTOR-APT-MENUPASS-001 - MenuPass
- **Issue**: The description correctly attributes MenuPass to the Tianjin State Security Bureau of the MSS, which is accurate per the 2018 DOJ indictment. No factual error, but the relation to MirrorFace using "enables" implies MenuPass directly enables MirrorFace, which may overstate the relationship. ESET research describes shared tooling rather than an "enables" relationship.
- **Correction**: Consider changing the relation type or description to better reflect "shared tooling and infrastructure" rather than direct enablement.

---

## Factual Accuracy Verification (Spot-Checked Atoms)

### Correctly Attributed APT Groups (verified accurate):
- **Cozy Bear / APT29**: Correctly attributed to Russian SVR. Aliases, operations (SolarWinds, DNC), and tooling accurate.
- **BlueNoroff / APT38**: Correctly attributed to North Korea/Lazarus umbrella. Bangladesh Bank heist, cryptocurrency focus accurate.
- **BlackTech**: Correctly attributed to China. Router firmware modification capability, NSA/FBI/CISA 2023 advisory referenced accurately.
- **MuddyWater**: Correctly attributed to Iranian MOIS per USCYBERCOM 2022 announcement. Aliases and tooling accurate.
- **OilRig / APT34**: Correctly attributed to Iranian MOIS. Lab Dookhtegan leak reference accurate.
- **OceanLotus / APT32**: Correctly attributed to Vietnam. Cross-platform capability and targets accurate.
- **ScarCruft / APT37**: Correctly attributed to North Korean MSS. Malware families and targeting accurate.
- **DarkHotel**: Correctly attributed to South Korea. Hotel Wi-Fi attack technique pioneering role accurate.
- **CactusPete / Tonto Team**: Correctly attributed to Chinese PLA. Bisonal RAT and targeting accurate.
- **Famous Chollima / Lazarus Group**: Correctly attributed to North Korean RGB. Sony Pictures, WannaCry, Bangladesh Bank heist accurate.
- **Diamond Sleet**: Correctly attributed to North Korea/Lazarus ecosystem. 3CX and CyberLink supply chain attacks accurate.
- **SideWinder**: Correctly attributed to India-nexus. High volume operations and Pakistan/China targeting accurate.
- **BadPilot**: Correctly described as Sandworm/Seashell Blizzard subgroup per Microsoft 2025 reporting. (But reference to Star Blizzard atom is wrong - see Major Issues.)
- **DeputyDog / APT17**: Correctly attributed to China. BLACKCOFFEE dead-drop resolver and TechNet abuse accurate.
- **Backdoor Diplomacy**: Correctly attributed to China. Turian backdoor evolution from Quarian accurate.
- **Moses Staff**: Correctly attributed to Iran. Marigold Sandstorm/DEV-0500 designations and ProxyShell exploitation accurate.

### Correctly Described Vendors (spot-checked):
- **DigiNotar**: 2011 breach, 500+ rogue certificates, Iran surveillance, bankruptcy -- all accurate.
- **CardinalOps**: SIEM optimization, detection engineering, ATT&CK mapping -- accurate.
- **NetSarang**: 2017 ShadowPad supply chain attack, Xshell compromise -- accurate.
- **SecureList**: Kaspersky research platform, GReAT team -- accurate.

### Correctly Described Research Orgs (spot-checked):
- **Project Zero**: Google team, founded 2014, 90-day disclosure policy, Spectre/Meltdown -- accurate.

---

## Structural Observations

1. **Relation Type Inconsistency**: The enriched files (Section 5 group, created in a first pass) consistently use valid relation types (is_a, part_of, enables, applies_to, precedes, supersedes, requires). The derived/second-pass files (Section 6-only format, many APT files) use numerous invalid types (uses, targets, attributed_to, consists_of, collaborates_with, exploits). The vendor files almost universally use "produces" and "provides" which are also invalid.

2. **Self-referencing is_a**: Approximately 20+ files have is_a relations targeting themselves, which is semantically null.

3. **Missing Sandworm/Seashell Blizzard Atom**: There is no atom for one of the most significant Russian APT groups (GRU Unit 74455 / Sandworm / Seashell Blizzard / IRIDIUM / Voodoo Bear). The BadPilot and ConfCrew atoms reference `ACTOR-APT-STARBLIZ-001` expecting Seashell Blizzard but finding Star Blizzard (SEABORGIUM/FSB) instead.

4. **Duplicate Entities**: At least 3 sets of duplicate atoms exist for the same threat actors:
   - APT29: Cozy Bear + Noble Baron + DarkHalo (3 atoms)
   - APT32: OceanLotus + Sea Lotus (2 atoms)
   - APT37: ScarCruft + Inky Squid (2 atoms)

---

## Recommendations

1. **Priority 1**: Create a Seashell Blizzard/Sandworm atom and fix BadPilot/ConfCrew references.
2. **Priority 2**: Systematically replace all invalid relation types across all 73 affected files.
3. **Priority 3**: Resolve duplicate entity atoms (APT29, APT32, APT37) by either consolidating or clearly cross-referencing.
4. **Priority 4**: Remove self-referencing is_a relations from ~20 files.
5. **Priority 5**: Review the generic `enables ATK-INITIAL-SPEARPHISH-001` relation on actors where spearphishing is not the primary access vector.
