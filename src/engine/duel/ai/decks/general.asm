DEF AI_DEBUG_TEXT_BOXES EQU FALSE

; AI logic used by general decks
AIActionTable_GeneralDecks:
	dw AIMainTurnLogic                ; .do_turn (unused)
	dw AIMainTurnLogic                ; .do_turn
	dw .start_duel
	dw AIDecideBenchPokemonToSwitchTo ; .forced_switch
	dw AIDecideBenchPokemonToSwitchTo ; .ko_switch
	dw AIPickPrizeCards               ; .take_prize

.start_duel
	call InitAIDuelVars
	jp AIPlayInitialBasicCards


; handle AI routines for a whole turn
AIMainTurnLogic:
; initialize variables
	call InitAITurnVars

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, BulbasaurName
	call DrawWideTextBox_WaitForInput
ENDC

	ld a, AI_TRAINER_CARD_PHASE_01
	call AIProcessHandTrainerCards

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, IvysaurName
	call DrawWideTextBox_WaitForInput
ENDC

	call HandleAIAntiMewtwoDeckStrategy
	jp nc, .try_attack

; handle Pkmn Powers

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, VenusaurName
	call DrawWideTextBox_WaitForInput
ENDC

	farcall HandleAIGoGoRainDanceEnergy
	farcall HandleAIDamageSwap
	farcall HandleAIPkmnPowers
	ret c ; return if turn ended

; process Trainer cards
; phase 2 through 4.

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, CharmanderName
	call DrawWideTextBox_WaitForInput
ENDC

	ld a, AI_TRAINER_CARD_PHASE_02
	call AIProcessHandTrainerCards

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, CharmeleonName
	call DrawWideTextBox_WaitForInput
ENDC

	ld a, AI_TRAINER_CARD_PHASE_03
	call AIProcessHandTrainerCards

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, CharizardName
	call DrawWideTextBox_WaitForInput
ENDC

	ld a, AI_TRAINER_CARD_PHASE_04
	call AIProcessHandTrainerCards

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, SquirtleName
	call DrawWideTextBox_WaitForInput
ENDC

; play Pokemon from hand
	call AIDecidePlayPokemonCard
	ret c ; return if turn ended

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, WartortleName
	call DrawWideTextBox_WaitForInput
ENDC

; process Trainer cards
; phase 5 through 12.
	ld a, AI_TRAINER_CARD_PHASE_05
	call AIProcessHandTrainerCards

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, BlastoiseName
	call DrawWideTextBox_WaitForInput
ENDC

	ld a, AI_TRAINER_CARD_PHASE_06
	call AIProcessHandTrainerCards

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, CaterpieName
	call DrawWideTextBox_WaitForInput
ENDC

	ld a, AI_TRAINER_CARD_PHASE_07
	call AIProcessHandTrainerCards

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, MetapodName
	call DrawWideTextBox_WaitForInput
ENDC

	ld a, AI_TRAINER_CARD_PHASE_08
	call AIProcessHandTrainerCards

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, ButterfreeName
	call DrawWideTextBox_WaitForInput
ENDC

	call AIProcessRetreat

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, PidgeyName
	call DrawWideTextBox_WaitForInput
ENDC

	ld a, AI_TRAINER_CARD_PHASE_10
	call AIProcessHandTrainerCards

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, PidgeottoName
	call DrawWideTextBox_WaitForInput
ENDC

	ld a, AI_TRAINER_CARD_PHASE_11
	call AIProcessHandTrainerCards

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, PidgeotName
	call DrawWideTextBox_WaitForInput
ENDC

	ld a, AI_TRAINER_CARD_PHASE_12
	call AIProcessHandTrainerCards

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, WeedleName
	call DrawWideTextBox_WaitForInput
ENDC

; play Energy card if possible
	ld a, [wOncePerTurnFlags]
	and PLAYED_ENERGY_THIS_TURN
	call z, AIProcessAndTryToPlayEnergy

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, KakunaName
	call DrawWideTextBox_WaitForInput
ENDC

; play Pokemon from hand again
	call AIDecidePlayPokemonCard
	ret c ; return if turn ended

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, BeedrillName
	call DrawWideTextBox_WaitForInput
ENDC

; handle Pkmn Powers again
	farcall HandleAIDamageSwap

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, RattataName
	call DrawWideTextBox_WaitForInput
ENDC

	farcall HandleAIPkmnPowers
	ret c ; return if turn ended

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, RaticateName
	call DrawWideTextBox_WaitForInput
ENDC

	farcall HandleAIGoGoRainDanceEnergy
	ld a, AI_ENERGY_TRANS_ATTACK
	farcall HandleAIEnergyTrans

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, SpearowName
	call DrawWideTextBox_WaitForInput
ENDC

; process Trainer cards phases 13 and 15
	ld a, AI_TRAINER_CARD_PHASE_13
	call AIProcessHandTrainerCards

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, FearowName
	call DrawWideTextBox_WaitForInput
ENDC

	ld a, AI_TRAINER_CARD_PHASE_15
	call AIProcessHandTrainerCards

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, PikachuName
	call DrawWideTextBox_WaitForInput
ENDC

; if used Professor Oak, process new hand
; if not, then proceed to attack.
	ld a, [wPreviousAIFlags]
	and AI_FLAG_USED_PROFESSOR_OAK

IF AI_DEBUG_TEXT_BOXES
	jp z, .try_attack 

	ldtx hl, RaichuName
	call DrawWideTextBox_WaitForInput
ELSE
	jr z, .try_attack
ENDC

	ld a, AI_TRAINER_CARD_PHASE_01
	call AIProcessHandTrainerCards

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, SandshrewName
	call DrawWideTextBox_WaitForInput
ENDC

	ld a, AI_TRAINER_CARD_PHASE_02
	call AIProcessHandTrainerCards

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, SandslashName
	call DrawWideTextBox_WaitForInput
ENDC

	ld a, AI_TRAINER_CARD_PHASE_03
	call AIProcessHandTrainerCards

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, NidoranFName
	call DrawWideTextBox_WaitForInput
ENDC

	ld a, AI_TRAINER_CARD_PHASE_04
	call AIProcessHandTrainerCards

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, NidorinaName
	call DrawWideTextBox_WaitForInput
ENDC

	call AIDecidePlayPokemonCard
	ret c ; return if turn ended

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, NidoqueenName
	call DrawWideTextBox_WaitForInput
ENDC

	ld a, AI_TRAINER_CARD_PHASE_05
	call AIProcessHandTrainerCards

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, NidoranMName
	call DrawWideTextBox_WaitForInput
ENDC

	ld a, AI_TRAINER_CARD_PHASE_06
	call AIProcessHandTrainerCards

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, NidorinoName
	call DrawWideTextBox_WaitForInput
ENDC

	ld a, AI_TRAINER_CARD_PHASE_07
	call AIProcessHandTrainerCards

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, NidokingName
	call DrawWideTextBox_WaitForInput
ENDC

	ld a, AI_TRAINER_CARD_PHASE_08
	call AIProcessHandTrainerCards

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, ClefairyName
	call DrawWideTextBox_WaitForInput
ENDC

	call AIProcessRetreat

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, ClefableName
	call DrawWideTextBox_WaitForInput
ENDC

	ld a, AI_TRAINER_CARD_PHASE_10
	call AIProcessHandTrainerCards

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, VulpixName
	call DrawWideTextBox_WaitForInput
ENDC

	ld a, AI_TRAINER_CARD_PHASE_11
	call AIProcessHandTrainerCards

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, NinetalesName
	call DrawWideTextBox_WaitForInput
ENDC

	ld a, AI_TRAINER_CARD_PHASE_12
	call AIProcessHandTrainerCards

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, JigglypuffName
	call DrawWideTextBox_WaitForInput
ENDC

	ld a, [wOncePerTurnFlags]
	and PLAYED_ENERGY_THIS_TURN
	call z, AIProcessAndTryToPlayEnergy

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, WigglytuffName
	call DrawWideTextBox_WaitForInput
ENDC

	call AIDecidePlayPokemonCard
	ret c ; return if turn ended

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, ZubatName
	call DrawWideTextBox_WaitForInput
ENDC

	farcall HandleAIDamageSwap

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, GolbatName
	call DrawWideTextBox_WaitForInput
ENDC

	farcall HandleAIPkmnPowers
	ret c ; return if turn ended

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, OddishName
	call DrawWideTextBox_WaitForInput
ENDC

	farcall HandleAIGoGoRainDanceEnergy

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, GloomName
	call DrawWideTextBox_WaitForInput
ENDC

	ld a, AI_ENERGY_TRANS_ATTACK
	farcall HandleAIEnergyTrans

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, VileplumeName
	call DrawWideTextBox_WaitForInput
ENDC

	ld a, AI_TRAINER_CARD_PHASE_13
	call AIProcessHandTrainerCards
	; skip AI_TRAINER_CARD_PHASE_15

.try_attack

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, ParasName
	call DrawWideTextBox_WaitForInput
ENDC

	ld a, AI_ENERGY_TRANS_TO_BENCH
	farcall HandleAIEnergyTrans

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, ParasectName
	call DrawWideTextBox_WaitForInput
ENDC

; attack if possible, if not,
; finish turn without attacking.
	call AIProcessAndTryToUseAttack
	ret c ; return if AI attacked

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, VenonatName
	call DrawWideTextBox_WaitForInput
ENDC

	ld a, OPPACTION_FINISH_NO_ATTACK
	bank1call AIMakeDecision

IF AI_DEBUG_TEXT_BOXES
	ldtx hl, VenomothName
	call DrawWideTextBox_WaitForInput
ENDC

	ret


; handles AI retreating logic
AIProcessRetreat:
	ld a, [wAIRetreatedThisTurn]
	or a
	ret nz ; return, already retreated this turn

	call AIDecideWhetherToRetreat
	ret nc ; return if not retreating

	call AIDecideBenchPokemonToSwitchTo
	ret c ; return if no Bench Pokemon

; store Play Area to retreat to and
; set wAIRetreatedThisTurn to true
	ld [wAIPlayAreaCardToSwitch], a
	ld a, TRUE
	ld [wAIRetreatedThisTurn], a
	ld hl, wPreviousAIFlags
	res 0, [hl] ; clear AI_FLAG_USED_PLUSPOWER so preselected attack will be ignored

; if AI can use Switch from hand, use it instead...
	ld a, AI_TRAINER_CARD_PHASE_09
	call AIProcessHandTrainerCards
	ld a, [wPreviousAIFlags]
	and AI_FLAG_USED_SWITCH
	jr nz, .used_switch
; ... else try retreating normally.
	ld a, AI_ENERGY_TRANS_RETREAT
	farcall HandleAIEnergyTrans
	ld a, [wAIPlayAreaCardToSwitch]
	jp AITryToRetreat

.used_switch
; if AI used switch, unset its AI flag
	ld a, [wPreviousAIFlags]
	and ~AI_FLAG_USED_SWITCH ; clear Switch flag
	ld [wPreviousAIFlags], a
	ret
