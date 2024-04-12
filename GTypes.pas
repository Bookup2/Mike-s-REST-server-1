unit GTypes;

interface

uses
  System.UITypes,

  SysUtils,

  DiagramTypes;

const
  {  $DEFINE TESTVERSION}       // FIXEDIN build 140
  {  $DEFINE BETATESTING}       // FIXEDIN build 140

    // And be sure to add support for reading previous release builds INI settings file.
    // Be sure it's unique to both Pro and Express builds
    // Add this new build to the Evernote desktop notes.
  // kProgramBuildNumber = '192';   // CHECK NOTES ABOVE   Changed to gProgramBuildNumber FIXEDIN build 192

    // This .INC file is created by a pre build event (Project | Options.. | Building | Build Events
    // Pre-build events | Commands | DelphiBuildNumberIncludeMaker.exe
    // "$(PROJECTDIR)\DelphiBuildNumberIncludeMaker.exe" "$(PROJECTDIR)"
  { $INCLUDE DelphiBuild.Inc}  // kDelphiBuildNumber = '28.x.x.x';  FIXEDIN build 167

  {$IFDEF TESTVERSION}
  kExpirationYear = 2023;   // Expires
  kExpirationMonth = 3;
  kExpirationDay = 3;
  {$ENDIF}

    // FIXEDIN build 127
    // All references to http:// were changed to https://

  kIconPNG = 'programiconpng';

  kMainWindowCaption = 'Chess Openings Wizard Professional';
  kProgramMutex = 'ChessOpeningsWizardProfessional';
  kProgramVersion = 'Chess Openings Wizard Professional';
  // kHelpFile = 'ChessOpeningsWizardProfessional.chm';


  kProgramTokenPhrase = '';    // FIXEDIN build 150

    // FIXEDIN build 113
    // INI file is used starting build 127 so no need for registry keys.
  kRegistryKeyPreferencesRecordBuild117 = 'Prefs build117';  // FIXEDIN build 118
  kRegistryKeyPreferencesRecordBuild113 = 'Prefs build113';  // FIXEDIN build 115
  kRegistryKeyPreferencesRecordBuild112 = 'Prefs build112';
  kRegistryKeyPreferencesRecordBuild92  = 'Prefs build92';

    // Changed to https:// in build 151    FIXEDIN build 151
  //kURLUpdateDownload ='https://www.bookup.com/cowupdates/build' + gProgramBuildNumber + '.txt';    // FIXEDIN build 192
  kUpdateDownloadFilename = 'updateavailable.txt';   // stored on hard drive
  // kUpdateURL = 'https://www.bookup.com/updates/build' + gProgramBuildNumber;   Now a global var   // FIXEDIN build 192

  // kRegistryKeyOlderPreferencesRecord = 'Prefs build112';                  //FIXEDIN build 112
  // kRegistryKeyOlderPreferencesRecord = 'Prefs build92';                   //FIXEDIN build 112

  // These are in BookXX.pas now.
  // kDataVersion = 103;
  // kDataVersionMinimumSupported = 103;

  // kURLCOWMacHelp = 'https://www.bookup.com/chess-openings-wizard-desktop/';  // FIXEDIN build 92

  kURLCOWLogin = 'https://www.bookup.com/login';  // FIXEDIN build 148

    // FIXEDIN build 91
  {$IFDEF MSWINDOWS}
  kURLHelpPrefix = 'https://www.bookup.com/chess-openings-wizard-desktop/';    // done
  {$ENDIF}

  {$IFDEF MACOS}
  kURLHelpPrefix = 'https://www.bookup.com/chess-openings-wizard-desktop/';    // done
  {$ENDIF}

  // kURLHelpDropboxWindow                            = kURLHelpPrefix + 'dropbox-window';      //  done               FIXEDIN build 158
  kURLHelpCloudStorageWindow                       = kURLHelpPrefix + 'desktop-cloud-storage-window';      //               FIXEDIN build 176
  kURLHelpPreTrainingWindow                        = kURLHelpPrefix + 'desktop-pre-training-window';      //  done      FIXEDIN build 176
  kURLHelpPreSynchronizeInformantRateSymbolsWindow = kURLHelpPrefix + 'desktop-synchronizing-informant-symbols';      //        FIXEDIN build 176
  kURLHelpPreFindNoveltiesByAssessmentWindow       = kURLHelpPrefix + 'desktop-finding-novelties';      //        FIXEDIN build 176
  // FIXEDIN build 137
  // kURLProgramUpdateOBSOLETE = 'https://www.chessopeningssoftware.com/versions/chessopeningswizardb' + kProgramBuildNumber + '.html';  // About Box

  kURLVideos = 'https://www.bookup.com/videos';
  kURLShoppingOnline = 'https://www.bookup.com/proshop.html';
  kURLLoggingIn = 'https://www.bookup.com/login';

  kMultimediaAudioTemporaryFileName = '$COWaudio$mp3.mp3';   // FIXEDIN build 137
  // kMultimediaAudioTemporaryWAVFileName = '$COWaudio$WAV.WAV';   // FIXEDIN build 137

  kUCIEngineLogFileName = 'UCI engine log file.TXT';

  kDefaultExportDiagramFileName = 'DiagramScreenshot';  // Extension added based on graphics format.  FIXEDIN build 187
  kCopyDiagramClipboardFileName = '$Clipboard$';        // Extension added based on graphics format.  FIXEDIN build 187

    // FIXEDIN build 176
  kCloudStorageDropbox     = 0;
  kCloudStorageGoogleDrive = 1;
  kClougStorageOneDrive    = 2;

  kMaximumCertainty = 3;

  kScreenGapBelowVCRButtons = 10;
  kScreenGapBelowDiagram = 5;
  kScreenGapLeftOfDiagram = 10;
  kScreenGapRightOfDiagram = 10;
  kScreenGapBetweenVCRButtons = 10;

  kVCRBackToStart    = 'vcrbacktostart';
  kVCRForwardToEnd   = 'vcrforwardtoend';
  kVCRNextBranch     = 'vcrnextbranch';
  kVCRPlay           = 'vcrplay';
  kVCRPreviousBranch = 'vcrpreviousbranch';
  kVCRTakeBack       = 'vcrtakeback';
  kGlyphNameDropDownEdit = 'dropdownedit';
  kGlyphNameCandidateComparisonMarker = 'candidatecomparisonmarker';

  kSpaceBetweenVCRButtons = 2;
  kSpaceBelowVCRButtons = 5;

  kNumberOfDaysInTemporaryExtension = 5.0;
  kTemporaryCode = '7777666655554444';  // NOT A REAL CODE - used to trigger a temporary code for 5 more days.

  kTempFootnoteFileName = '$SHEET1$.TMP';
  kTempSheetFileName = '$SheetTemp$';
  kTempImportPGNFileName = '$PGNIMPORT$.PGN';

  // kPreferencesFileName = 'ChessOpeningWizardPrefs' + gProgramBuildNumber + '.set';    // FIXEDIN build 192
  // kPreferencesFileNameBuild104 = 'ChessOpeningWizardPrefs104.set';     // FIXEDIN build 118
  kPreferencesFileNameBuild107 = 'ChessOpeningWizardPrefs107.set';     // FIXEDIN build 128

  // These are no longer needed.   FIXEDIN build 192
  // kProgramPreferencesINIFileName = 'ChessOpeningWizardPrefs' + kProgramBuildNumber + '.INI';  // FIXEDIN build 192
  // kProgramPreferencesINIFileNameBuild127 = 'ChessOpeningWizardPrefs127.INI';
  // kProgramPreferencesINIFileNameBuild132 = 'ChessOpeningWizardPrefs132.INI';
  // kProgramPreferencesINIFileNameBuild156 = 'ChessOpeningWizardPrefs156.INI';
  // kProgramPreferencesINIFileNameBuild160 = 'ChessOpeningWizardPrefs160.INI';      // FIXEDIN BUILD 167
  // kProgramPreferencesINIFileNameBuild168 = 'ChessOpeningWizardPrefs168.INI';      // FIXEDIN BUILD 176
  // kProgramPreferencesINIFileNameBuild171 = 'ChessOpeningWizardPrefs171.INI';      // FIXEDIN BUILD 176
  // kProgramPreferencesINIFileNameBuild176 = 'ChessOpeningWizardPrefs176.INI';      // FIXEDIN BUILD 181
  // kProgramPreferencesINIFileNameBuild181 = 'ChessOpeningWizardPrefs181.INI';      // FIXEDIN BUILD 183
  // kProgramPreferencesINIFileNameBuild183 = 'ChessOpeningWizardPrefs183.INI';      // FIXEDIN BUILD 188

  // Mac INI files.
  // kProgramPreferencesINIFileNameBuild161 = 'ChessOpeningWizardPrefs161.INI';      // FIXEDIN BUILD 180
  // kProgramPreferencesINIFileNameBuild177 = 'ChessOpeningWizardPrefs177.INI';      // FIXEDIN BUILD 180
  // kProgramPreferencesINIFileNameBuild180 = 'ChessOpeningWizardPrefs180.INI';      // FIXEDIN BUILD 182
  // kProgramPreferencesINIFileNameBuild182 = 'ChessOpeningWizardPrefs182.INI';      // FIXEDIN BUILD 184
  // kProgramPreferencesINIFileNameBuild184 = 'ChessOpeningWizardPrefs184.INI';      // FIXEDIN BUILD 187

  kGameMasterTreeFileName = 'Pedigree2600.GMT';
  kECOMasterFileName = 'ECOMAST.4MD';

  // kNumberOfDaysInTrial = 30.0;
  // kNumberOfDaysForTemporaryCode = 10.0;
  // kTemporaryCode = '5555444433332222';  // NOT A REAL CODE - used to trigger a temporary code for 10 more days.

  {$IFDEF MSWINDOWS}
  kRegistryKeySoftware = 'Software';
  kRegistryKeyCompany = 'Bookup';
  // kRegistryKeyProgramPreviousVersion = 'Chess Openings Wizard Professional 2016';  // FIXEDIN build 153
  kRegistryKeyProgram = 'Chess Openings Wizard Professional';   // FIXEDIN build 141   It used to have 2016 at the end.
  kRegistryKeyProgramForOlderVersion = 'Chess Openings Wizard Professional 2016';   // FIXEDIN build 141
  // kRegistryKeyPreferencesRecord = 'Prefs build' + kProgramBuildNumber;              // FIXEDIN build 192
  kRegistryKeyInstallerSettings = 'Installer Settings 2021';
  kRegistryKeyInstallerSettingsForOlderVersion = 'Installer Settings';             // FIXEDIN build 141
  kRegistryKeyInstallerSettingsDataFolder = 'DataFolder';

  kRegistryValueTemporaryEndsDate = 'Product Key Temporary';
  kRegistryValueProductKey = 'Product Key';
  kProductKeyFileName = 'winproproductkey.dat';
  {$ENDIF}


  {$IFDEF MACOS}
  kMacProductKeyFileName = 'macproproductkey.dat';                    // FIXEDIN build 80
  kMacProductKeyStoredFileName = 'macproductkey.txt';                 // FIXEDIN build 80
  kMacApplicationSupportSubFolder = 'com.bookup.chessopeningswizardprofessional';
  {$ENDIF}

  // kRegistryKeyPreferencesRecord = 'Prefs build' + kProgramBuildNumber;

  kTrainingMaximumMoveSpeedTimes = 5;

  kFileNameECOMasterDescriptions = 'ECOMAST.4MD';
  kFileNameAudioTestFile = 'audioplaybacktestfile.mp3';

  kFolderNameCompany = 'Bookup';
  kFoldernameProduct = 'Chess Openings Wizard';       // FIXEDIN build 141    used to end with 2016
  kFoldernameProduct2016 = 'Chess Openings Wizard 2016';       // FIXEDIN build 141    Needed for locating older INI files.
  kFolderNameRootData = 'Chess Openings Wizard';      // FIXEDIN build 141    used to have 2016
  kFolderNameSampleEbooks = 'Sample Data';            // FIXEDIN build 140
  kFolderNameEbook = 'Ebooks';
  kFolderNameGame = 'Games';
  kFolderNameEPD = 'EPD';
  kFolderNameEngine = 'Engines';
  kFolderNameResources = 'Resources';
  kFolderNameText = 'Text';
  kFolderNameTemporary = 'Temp';
  kFolderNameAnalysis = 'Analysis';
  kFolderNameGameMasterTree = 'Game Trees';
  kFolderNameTestFiles = 'Test Files';                 // FIXEDIN build 146
  kFolderNameICCWindowsDatabase = 'My Chess Database';
  kFolderNameICCMacintoshDatabase = 'Chess Database';

  kLightSquareColorOffWhite = 14483455; // buff    (European settings)
  kDarkSquareColorBrown = 4953780;   // tan, offwhite;
  kLightSquareColorBuff = 8454143; { a subdued yellow "buff" clWhite; }
  kDarkSquareColorGreen = 32768; { clGreen; }

  // kINIChessOpeningsWizardFileName = 'COW.INI';
  kINIEbooksFileName = 'COWebooks3.INI';     // FIXEDIN build 140  to not open previous data format ebooks
  kINIGamesFileName = 'COWgames.INI';
  kINIWatchedPGNFileName = 'COWwatchpgn.INI';

  kSentinelValue = $0F0F0F0F;

  {------------------ Keystrokes -------------------}
  kNull = #0;
  kCtrlC = #3;
  kBackSpace = #8;
  kTab = #9;
  kLineFeed = #10;
  kCarriageReturn = #13;
  kEnter = #13;

  {------------------ GameMaster style move encoding used in MasterChess -----------------}
  kSpecialMoveByte = #47;  { a slash (/) }
  kAlphabetOffset = 48;

  {------------------ Limits -------------------}
  kMaximumMultimediaScriptCharacters = 60000;

  kMaximumCommentColumns = 74;

  kMaximumCommentCharacters = 60000;

  kMaximumCandidates = 30;
  kMaximumUnCandidates = 30;
  kMaximumPlies = 500;

  // kMaximumGameTitleLength = 41;
  kMaximumPositionSetNameLength = 255;
  kMaximumOpeningCodeLength = 9;
  kMaximumGameHeaderTextLength = 60;

  kMaximumBackSolveTotal = 50000;

  kTrainingComputerPlaysWhite = 0;
  kTrainingComputerPlaysBlack = 1;
  kTrainingComputerPlaysBothSides = 2;
  kTrainingComputerPlaysNotAtAll = 3;

  kInformantBookupFontCharacterWhiteWins        = 'i';
  kInformantBookupFontCharacterWhiteBetter      = 'j';
  kInformantBookupFontCharacterWhiteAd          = 'k';
  kInformantBookupFontCharacterEqual            = 'l';
  kInformantBookupFontCharacterUnclear          = 'm';
  kInformantBookupFontCharacterWithCompensation = 'n';
  kInformantBookupFontCharacterBlackAd          = 'o';
  kInformantBookupFontCharacterBlackBetter      = 'p';
  kInformantBookupFontCharacterBlackWins        = 'q';
  kInformantBookupFontCharacterNoRate           = 'r';
  kInformantBookupFontCharacterLoop             = 'g';

  {------------------ Languages ------------------------}
  kLanguageEnglish = 0;
  kLanguageGerman = 2000;
  kLanguageItalian = 4000;
  kLanguageSpanish = 6000;
  kLanguageFrench = 8000;
  kLanguageIcelandic = 10000;
  kLanguageDutch = 12000;
  kLanguageSwedish = 14000;
  kLanguageRussian = 16000;


  {------------------ Help Contexts --------------------}
  kHelpContextWelcome = 6259;
  kHelpContextFENNamingInstructions = 5053;
  kHelpContextResetTrainingCoverage = 6004;
  kHelpContextPreferencesHelpButton = 1952;
  kHelpContextRegisterOrContinueTrialButton = 1775;
  kHelpContextPreferencesAdvancedTab = 1959;

  {------------------ Dialog strings -------------------}
  kDlgStrBlank = 0;

{ kDlgStrNotEnoughMemoryToRun = 1;
  kDlgStrThanksForUsing = 2;
  kDlgStrPressAnyKeyToContinue = 3;
  kDlgStrProgramInconsistency = 4;
  kDlgStrBecomeGopherCalledWhenGopherNil = 5;   }

  kDlgStrCorruptionWarning = 6;
  kDlgStrGBSIFCHasIllegalMove = 7;

  kDlgStrCalculateUncandidatesHasIllegalMove = 8;

{ kDlgStrClearNumericAssessmentsInternalProblem = 8; }

  kDlgStrNoTargetPositionAfter = 9;

{ kDlgStrNoChangesSavedWhileTraining = 10; }

  kDlgStrNoCandidateIsHighlighted = 11;
  kDlgStrCandidateIsAlreadyAtTheTop = 12;
  kDlgStrCandidateIsAlreadyAtTheBottom = 13;
  kDlgStrThereIsNoRecordAtThisLocation = 14;
  kDlgStrBoardInThisLocationIsNotInTheIndexOrIsCorrupt = 15;
  kDlgStrThereAreNoNamedPositionsInThisBook = 16; 
  kDlgStrThereWasAProblemJumpingToThePosition = 17;

{ kDlgStrIsNotABoardNameOrFileLocation = 18; }

  kDlgStrThereWasAProblemLoadingTheGame = 19;
  kDlgStrThereAreNoGamesRecordedInThisBook = 20;
  kDlgStrThereAreNoMoreGames = 21; 
  kDlgStrThereAreNoMoreNamedPositions = 22;
  kDlgStrNoneOfTheCandidatesArePartOfTheGame = 23;

  kDlgStrNewChessBook = 24;
  kDlgStrOpenChessBook = 25;

  kDlgStrMakeMoveHasAnIllegalMove = 26;

{ kDlgStrThisFileNameCannotBeUsed = 27;
  kDlgStrProgramOrMemoryProblem = 28;
  kDlgStrThereWasAProblemCreatingTheNewBook = 29;  }

  kDlgStrNoMoreMovesCanBePlayed = 30;

{ kDlgStrProgramOrBookError = 31; }

  kDlgStrNoGameIsLoadedThisButtonStopsAnimation = 32;
  kDlgStrGameIsNotBeingAnimatedThisButtonStopsAnimation = 33;
  kDlgStrGameAnimationHasBeenStopped = 34;
  kDlgStrNoMoreCandidatesCanBeAdded = 35;
  kDlgStrAddCandidateHasAnIllegalMove = 36;
  kDlgStrThereAreNoMovesToTakeBackThisButtonLastBranch = 37;
  kDlgStrThereAreNoCandidatesThisButtonNextBranch = 38;
  kDlgStrNoGameIsLoadedThisButtonEndOfGame = 39;
  kDlgStrNoneOfTheseCandidatesBelongToTheGame = 40;
  kDlgStrProgramProblem = 41;  
  kDlgStrForwardToEndOfGameWasPassedAnIllegalMove = 42; 
  kDlgStrNotInTheBook = 43;
  kDlgStrNotTheTopCandidate = 44;

  kDlgStrThereWasAProblemOpeningThisFile = 45;

  kDlgStrTroubleDeletingTheBookmark = 47;

{ kDlgStrRebuildBook = 48;
  kDlgStrRebuildTheMainDatabase = 49;
  kDlgStrRebuildTheGameDatabase = 50;
  kDlgStrRebuildTheBoardDatabase = 51;
  kDlgStrOperationCancelledNothingToRebuild = 52;
  kDlgStrThisProcessCouldMakeLargeChangesRebuild = 53;
  kDlgStrRebuildOperationHasBeenCancelled = 54;
  kDlgStrAnErrorHasOccurredInTheProgram = 55;
  kDlgStrVersion = 56;
  kDlgStrTheErrorCodeIs = 57;
  kDlgStrTheErrorAddressIs = 58;
  kDlgStrPleaseNoteTheseCodeAndAddressNumbers = 59;
  kDlgStrTechnicalSupportIsAvailableInTheUS = 60;
  kDlgStrHoursAre9to6MondayThroughFriday = 61;
  kDlgStrInsideTheUSCallTollFree = 62;
  kDlgStrOutsideTheUSCallOrFax = 63;
  kDlgStrAnotherTrainingGame = 64;
  kDlgStrThisCommandIsNotActiveNow = 65;
  kDlgStrThisCommandIsNotSupported = 66; }

  kDlgStrNoMoreCandidates = 67;

{ kDlgStrgrSetEventMaskFailed = 68;
  kDlgStrgrClearEventsFailed = 69;
  kDlgStrThereIsNotEnoughMemoryForThe2DChessPieces = 70;
  kDlgStrCouldNotLoadThePCXChessPieces = 71;  }

  kDlgStrDatabaseProblem = 72;

{ kDlgStrCaution = 73;
  kDlgStrNewBook = 74;
  kDlgStrNewBookName = 75;
  kDlgStrTraining = 76;
  kDlgStrExportEPD = 77; }

  kDlgStrBookmark = 78;

{ kDlgStrOpenBook = 79;  }

  kDlgStrGame = 80;

{ kDlgStrAppend = 81;
  kDlgStrErase = 82; 
  kDlgStrEPDAll = 83;
  kDlgStrEPDLeaf = 84;
  kDlgStrEPDCurrent = 85;
  kDlgStrExit = 86;
  kDlgStrAreYouSureYouWantToLeaveTheProgram = 87; }

  kDlgStrNoMovesHaveBeenPlayed = 88;
  kDlgStrThereWasAProblemSavingTheGame = 89;

{ kDlgStrNotEnoughRAM = 90;  
  kDlgStrNewSheet = 91;
  kDlgStrNewSheetName = 92;
  kDlgStrCreateDiagramPCX = 93;
  kDlgStrPCXFileName = 94;
  kDlgStrPCXFileExtension = 95;
  kDlgStrReplaceTheExistingPCXFile = 96;
  kDlgStrThePCXFileWasNotCreated = 97;
  kDlgStrFileProblem = 98;
  kDlgStrThePCXFileCouldNotBeCreated = 99;
  kDlgStrThereWasAProblemGettingTheDisplayPalette = 100;
  kDlgStrThereWasAProblemSettingThePCXFilePalette = 101;
  kDlgStrOpenASCIITextFile = 102;
  kDlgStrImportText = 103;
  kDlgStrOpenPGNFile = 104;
  kDlgStrImportPGN = 105;
  kDlgStrOpenEPDTextFile = 106;
  kDlgStrImportEPD = 107;
  kDlgStrOpenOld7 = 108;
  kDlgStrThereWasAProblemOpeningTheDatabase = 109;
  kDlgStrBookNameIsBlank = 110;
  kDlgStrAddABook = 111;
  kDlgStrThereWasAProblemStartingTheProcess = 112;
  kDlgStrNotEnoughRAMForBacksolving = 113;
  kDlgStrThereWasAProblemReadingThisFile = 114;
  kDlgStrAbout = 115;
  kDlgStrThisCartoon = 116;
  kDlgStrCartoonDescription = 117;
  kDlgStrAboutThisBook = 118;
  kDlgStrBookNameIs = 119;
  kDlgStrNumberOfPositionsIs = 120;
  kDlgStrNumberOfGamesIs = 121;
  kDlgStrNumberOfNamedPositionsIs = 122;
  kDlgStrNoBookIsCurrentlyOpen = 123;
  kDlgStrAnimateGame = 124;
  kDlgStrDelayMustBeFromZeroTo99Seconds = 125;
  kDlgStrNumberOfSecondsBetweenMoves = 126;  }

  kDlgStrClearingExistingUncandidates = 125;
  kDlgStrCalculatingNewUncandidates = 126;
  kDlgStrClearingNumericAssessments = 127;
  kDlgStrClearingRateSymbols = 128;

{ kDlgStrPositionsUpdated = 129;
  kDlgStrChangeNumericAssessment = 130;
  kDlgStrAssessmentsRangeFromNegative32000ToPositive32000 = 131;
  kDlgStrNewAssessmentForThisPosition = 132;
  kDlgStrImportingOld7 = 133;
  kDlgStrSetFPos20ReturnedAnError = 134;
  kDlgStrFSRead31ReturnedAnError = 135;
  kDlgStrFirstB7PositionDoesNotMatchInitialB8 = 136;
  kDlgStrOld7DataError = 137;
  kDlgStrIllegalMoveInTheOld7Data = 138;
  kDlgStrFilePositionIs = 139;
  kDlgStrTotal = 140;
  kDlgStrCandidateMoveFoundHasAnIllegalMove = 141;
  kDlgStrDatabaseError = 142;
  kDlgStrUnused1 = 143;
  kDlgStrPositions = 144;
  kDlgStrNames = 145;
  kDlgStrVariations = 146;
  kDlgStrBackSolvingSettings = 147;
  kDlgStrBackSolveNumericAssessmentsYN = 148;
  kDlgStrBackSolveRateSymbolsYN = 149;
  kDlgStrBackSolveAccumulationsYN = 150; }

  kDlgStrBackSolving = 151;

{ kDlgStrThisAmountOfDiskSpaceisNeededToBacksolve = 152;
  kDlgStrANewTemporaryBacksolveFileCouldNotBeCreated1 = 153;
  kDlgStrANewTemporaryBacksolveFileCouldNotBeCreated2 = 154;
  kDlgStrTheBacksolveCouldNotSolveSomeRepetitionsTheyWillBeSetToEqual = 155;
  kDlgStrPassNumber = 156;
  kDlgStrProcessing = 157;
  kDlgStrSolvedThisPass = 158;
  kDlgStrSolvedPositions = 159;
  kDlgStrTotalPositions = 160;
  kDlgStrPercentageComplete = 161;
  kDlgStrProblemReadingTheTemporaryBacksolveFile1 = 162;
  kDlgStrProblemReadingTheTemporaryBacksolveFile2 = 163;
  kDlgStrProblemReadingTheTemporaryBacksolveFile3 = 164;
  kDlgStrProblemReadingTheTemporaryBacksolveFile4 = 165;
  kDlgStrProblemRewritingTheTemporaryBacksolveFile1 = 166;
  kDlgStrProblemWithTheTemporaryBacksolveFile2 = 167;
  kDlgStrBackSolvingProcessIsFindingTooManyPositions = 168;
  kDlgStrBackSolveHasAnInternalError = 169;
  kDlgStrProgramIsBacksolvingAPositionWithoutCandidates = 170;
  kDlgStrBackSolveFoundAnIllegalMove = 171;
  kDlgStrBackSolveCouldNotFindATargetPosition = 172; }

  kDlgStrThereWasAProblemCreatingTheMainFileForThisBook = 173;
  kDlgStrThereWasAProblemCreatingTheGameFileForThisBook = 174;
  kDlgStrThereWasAProblemCreatingTheNameFileForThisBook = 175;
  kDlgStrThereWasAProblemOpeningTheMainDatabase = 176;
  kDlgStrThereWasAProblemOpeningTheGameDatabase = 177;
  kDlgStrThereWasAProblemOpeningTheNameDatabase = 178; 
  kDlgStrCBookDoneThereWasAProblemClosingTheMainFile = 179;
  kDlgStrCBookDoneThereWasAProblemClosingTheGameFile = 180;
  kDlgStrCBookDoneThereWasAProblemClosingTheNameFile = 181;
  kDlgStrNotEnoughDiskSpace = 182; 
  kDlgStrCBookUpdateEverythingBTFindKeyHadAnIsamError = 183;
  kDlgStrCBookUpdateEverythingBTPutVariableRecWasNotIsamOK = 184;
  kDlgStrCBookUpdateEverythingBTAddVariableRecWasNotIsamOK = 185;
  kDlgStrCBookUpdateEverythingBTAddKeyWasNotIsamOK = 186;
  kDlgStrCBookFileLocationOfBoardBTFindKeyHadAnIsamError = 187;
  kDlgStrCBookFillInEverythingBTFindKeyHadAnIsamError = 188;
  kDlgStrCBookFillInEverythingBTGetVariableRecWasNotIsamOK = 189;
  kDlgStrCBookFillInEverythingOpeningCodeWasWeirdSize = 190;
  kDlgStrCBookGetPositionCodeForThisBoardBTFindKeyHadAnIsamError = 191;
  kDlgStrCBookGetPositionCodeForThisBoardBTGetVariableRecWasNotIsamOK = 192;
  kDlgStrCBookUpdateBoardNameBTFindKeyHadAnIsamError = 193;
  kDlgStrCBookUpdateBoardNameBTAddRecWasNotIsamOK = 194;
  kDlgStrCBookUpdateBoardNameBTAddKeyWasNotIsamOK = 195;
  kDlgStrCBookDeleteBoardNameBTFindKeyHadAnIsamError1 = 196;
  kDlgStrCBookDeleteBoardNameBTDeleteKeyWasNotIsamOK = 197;
  kDlgStrCBookDeleteBoardNameBTDeleteRecWasNotIsamOK = 198;
  kDlgStrCBookThisBoardNameExistsBTKeyExistsHadAnIsamError = 199;
  kDlgStrCBookSaveGameBTFindKeyHadAnIsamError = 200;
  kDlgStrCBookSaveGameBTPutRecWasNotIsamOK = 201;
  kDlgStrCBookSaveGameBTAddRecWasNotIsamOK = 202;
  kDlgStrCBookFillInEverythingBoardsDontCheckOut1 = 203;
  kDlgStrCBookFillInEverythingBoardsDontCheckOut2 = 204;
  kDlgStrCBookFillInEverythingRecordLengthsDontMatchUp3 = 205;
  kDlgStrCBookSaveGameBTAddKeyWasNotIsamOK = 206;
  kDlgStrCBookLoadGameCalledWithBadKey = 207;
  kDlgStrCBookLoadGameBTGetRecWasNotIsamOK = 208;
  kDlgStrCBookLoadGameGameTitlesDontMatchUp = 209;
  kDlgStrCBookRenameGameBTFindKeyHadAnIsamError = 210;
  kDlgStrCBookRenameGameBTDeleteKeyWasNotIsamOK = 211;
  kDlgStrCBookRenameGameBTAddKeyWasNotIsamOK = 212;
  kDlgStrCBookRenameGameCalledWithBadKey = 213;
  kDlgStrCBookRenameBoardBTFindKeyHadAnIsamError = 214;
  kDlgStrCBookRenameBoardBTDeleteKeyWasNotIsamOK = 215;
  kDlgStrCBookRenameBoardBTAddKeyWasNotIsamOK = 216;
  kDlgStrCBookRenameBoardCalledWithBadKey = 217;
  kDlgStrCBookGetNameForThisBoardBTGetRecWasNotIsamOK1 = 218;
  kDlgStrCBookGetNameForThisBoardBTGetRecWasNotIsamOK2 = 219;
  kDlgStrCBookGetBoardForThisNameBTFindKeyHadAnIsamError1 = 220;
  kDlgStrCBookGetBoardForThisNameBTGetRecWasNotIsamOK1 = 221;
  kDlgStrCBookDeleteGameBTDeleteKeyWasNotIsamOK = 222;
  kDlgStrCBookDeleteGameBTDeleteRecWasNotIsamOK = 223;
  kDlgStrCBookDeleteGameTitleBTFindKeyHadAnIsamError = 224;
  kDlgStrCBookThisGameTitleExistsBTFindKeyHadAnIsamError = 225;
  kDlgStrGreaterKeysExistWasCalledWithAnUnsupportedValue = 226;
  kDlgStrPackRateInWasPassedABadRate = 227;
  kDlgStrCBookGetBoardAtFileLocationBTGetVariableRecWasNotIsamOK = 228;

{ kDlgStrAddingABook = 229;
  kDlgStrThereWasAProblemOpeningTheBookToAdd = 230;
  kDlgStrGames = 231; }

  kDlgStrImportingABook = 232;

{ kDlgStrThereWasAProblemOpeningTheBookToImport = 233;
  kDlgStrNotEnoughDriveSpaceForTheTemporaryFile = 234;
  kDlgStrInconsistencyInTheImportedBook1 = 235;
  kDlgStrInconsistencyInTheImportedBook2 = 236;
  kDlgStrInconsistencyInTheImportedBook3 = 237;
  kDlgStrIllegalMoveInTheImportedBook1 = 238;
  kDlgStrMoreInformation = 239;
  kDlgStrFromSquareIs = 240;
  kDlgStrToSquareIs = 241;
  kDlgStrFileLocationIs = 242;
  kDlgStrTheProblemIsWithThisMove = 243;
  kDlgStrPreparing = 244;
  kDlgStrInternalErrorWithTemporaryBoardFile1 = 245;
  kDlgStrInternalErrorWithTemporaryBoardFile2 = 246;
  kDlgStrErrorReadingTheTemporaryBoardFile = 247;
  kDlgStrErrorWritingToTheTemporaryBoardFile = 248;
  kDlgStrARequiredLetterIsNotFilledIn = 249;
  kDlgStrThereIsNoPieceOnThisSquare = 250;
  kDlgStrItIsWhitesTurnToMoveHere = 251;
  kDlgStrItIsBlacksTurnToMoveHere = 252;
  kDlgStrChangeDirectory = 253;
  kDlgStrThisDirectoryCannotBeFound = 254;
  kDlgStrNewDirectory = 255;
  kDlgStrChangeEPDSettings = 256;
  kDlgStrImport = 257;
  kDlgStrExport = 258;
  kDlgStrReplaceExistingDataYN = 259;
  kDlgStrPositiveForWhiteYN = 260;
  kDlgStrAppendOrEraseAE = 261;
  kDlgStrAllLeafOrCurrentALC = 262;
  kDlgStrOnlyBlankAssessmentsYN = 263;
  kDlgStrEPDFileName = 264;
  kDlgStrAppendOrEraseSettingMustBeAppendOrErase = 265;
  kDlgStrSettingMustBeAllLeafOrCurrent = 266;
  kDlgStrEPDFileNameMustBeFilledIn = 267;
  kDlgStrExportingEPD = 268;
  kDlgStrPositionsWritten = 269;
  kDlgStrImportingEPD = 270;
  kDlgStrPositionsProcessed = 271; }

  kDlgStrThereIsAProblemInterpretingTheEPDFile = 272;
  kDlgStrAnImportedPositionDidNotExistInThisBook = 273;

{ kDlgStrContinueTheImport = 274; }

  kDlgStrProblemInterpretingThisNumericAssessment = 275;

{ kDlgStrChangeExportSettings = 276;
  kDlgStrCommentsNES = 277;
  kDlgStrMovesCP = 278;
  kDlgStrTabsAtLeft09 = 279;
  kDlgStrCarriageReturnsAfter09 = 280;
  kDlgStrStartAtMove = 281;
  kDlgStrStopAtMove = 282;
  kDlgStrStartWithWhitesMove = 283;
  kDlgStrMovesNumbersSPB = 284;
  kDlgStrExportFileName = 285;
  kDlgStrExportCommentsNone = 286;
  kDlgStrExportCommentsEmbed = 287;
  kDlgStrExportCommentsSeparate = 288;
  kDlgStrCommentsSettingMustBeNoneEmbedOrSeparate = 289;
  kDlgStrExportMovesColumnar = 290;
  kDlgStrExportMovesParagraph = 291;
  kDlgStrMovesSettingMustBeColumnarOrParagraph = 292;
  kDlgStrExportMoveNumbersSpace = 293;
  kDlgStrExportMoveNumbersPeriod = 294;
  kDlgStrExportMoveNumbersBoth = 295;
  kDlgStrMoveNumbersSettingMustBeSpacePeriodOrBoth = 296;
  kDlgStrNumberOfTabsMustBeFrom0To9 = 297;
  kDlgStrNumberOfReturnsMustBeFrom0To9 = 298;
  kDlgStrStartExportAtMoveMustBeFrom1To999 = 299;
  kDlgStrStopExportAtMoveMustBeFrom1To999 = 300;
  kDlgStrStartExportMustBeGreaterThanStopExport = 301;
  kDlgStrExportFileNameMustBeFilledIn = 302;
  kDlgStrImportingGames = 303; }

  kDlgStrResultUnknown = 304;

{ kDlgStrGamesImported = 305;
  kDlgStrLinesRead = 306;
  kDlgStrGameHeaderText = 307;
  kDlgStrTextGameImportSettings = 308;
  kDlgStrTextFileExtension = 309;
  kDlgStrPliesToImport = 310;
  kDlgStrSuppressDuplicateComments = 311;
  kDlgStrRecordGamesByFirstHeaderLine = 312;
  kDlgStrPutGameHeadersInLastPosition = 313;
  kDlgStrTheLettersInTheTextFileExtensionCannotBeUsed = 314;
  kDlgStrPliesToImportMustBeFrom5To999 = 315;
  kDlgStrOnlyNumbersCanBeKeyedHere = 316;
  kDlgStrJumpToBoard = 317;
  kDlgStrBoardNameCannotBeBlank = 318;
  kDlgStrBoardNameOrNumber = 319;
  kDlgStrJumpToPositionName = 320;
  kDlgStrNoBoardNameHasBeenSelected = 321;
  kDlgStrUnused2 = 322;  }

  kDlgStrAreYouSureYouWantToDeleteThisBoardName = 323;

{ kDlgStrThereWasAProblemDeletingTheBoardName = 324;
  kDlgStrLoadGame = 325;
  kDlgStrUnused3 = 326;
  kDlgStrAreYouSureYouWantToDeleteThisGame = 327;
  kDlgStrThereWasAProblemDeletingTheGame = 328;
  kDlgStrFileNamesMustBeFrom1To8Characters = 329;
  kDlgStrOverwriteThisFile = 330;
  kDlgStrNoFileHasBeenSelected = 331;
  kDlgStrNoGameHasBeenSelected = 332;
  kDlgStrRed = 333;
  kDlgStrGreen = 334;
  kDlgStrBlue = 335;
  kDlgStrCParserInitIsFailingDueToNoMemoryForItsPosition = 336; }

  kDlgStrNotationForThisMoveCannotBeMade = 337;
  kDlgStrCParserNotationForUnrecognizablePiece = 338;
  kDlgStrMakeMoveNotationHasAnIllegalMove = 339;
  kDlgStrCParserGetChessMoveWasCalledItsNotationIsOKIsFalse = 340;
  kDlgStrAWhiteKingCouldNotBeFound = 341;
  kDlgStrABlackKingCouldNotBeFound = 342;
  kDlgStrRound = 343;

{ kDlgStrPGNImportSettings = 344;
  kDlgStrUnused4 = 345;
  kDlgStrRecordGamesByPlayerNames = 346;
  kDlgStrTheEnPassantSquareForThisBoardIsNotCorrect = 347;
  kDlgStrPieceOnSquareWasPassedAnEdgeSquare = 348;
  kDlgStrPutPieceOnSquareWasPassedAnEdgeSquare = 349;
  kDlgStrEPDProblem = 350;
  kDlgStrTheEnPassantSquareWasNotCorrect = 351;
  kDlgStrChangePreferences = 352;
  kDlgStrKing = 353;
  kDlgStrQueen = 354;
  kDlgStrRook = 355;
  kDlgStrBishop = 356;
  kDlgStrKnight = 357;
  kDlgStrPawn = 358;
  kDlgStrIndicateChecks = 359;
  kDlgStrIndicateCaptures = 360;
  kDlgStrPromotionPiece = 361;
  kDlgStrVariationBeginsMove = 362;
  kDlgStrSlidingPieceDelay = 363;
  kDlgStrSortCandidatesByNRA = 364;
  kDlgStrPieceLettersMustBeUppercaseLetters = 365;
  kDlgStrEachPieceLetterMustBeUnique = 366;
  kDlgStrThePromotionPieceLetterIsNotCorrect = 367;
  kDlgStrVariationMustBeginWithMove1To999 = 368;
  kDlgStrTheDelayMustBeFrom0To9 = 369;
  kDlgStrSortCandidatesNotAtAll = 370;
  kDlgStrSortCandidatesByRate = 371;
  kDlgStrSortCandidatesByAssessment = 372;
  kDlgStrCandidatesMustBeSortedByRateOrAssessmentOrNotSorted = 373;  }

  kDlgStrKingLetter = 374;
  kDlgStrQueenLetter = 375;
  kDlgStrRookLetter = 376;
  kDlgStrBishopLetter = 377;
  kDlgStrKnightLetter = 378;
  kDlgStrPawnLetter = 379;

{ kDlgStrRecordGame = 380; }

  kDlgStrAGameTitleCannotBeBlank = 381;

{ kDlgStrReplaceTheExistingGameThatHasThisName = 382;
  kDlgStrGameTitle = 383;
  kDlgStrRenamePosition = 384;
  kDlgStrAPositionNameCannotBeBlank = 385;  }

  kDlgStrOverwriteTheExistingPositionThatHasThisName = 386;

{ kDlgStrRenamePositionTo = 387;
  kDlgStrRenameGame = 388;
  kDlgStrUnused5 = 389;
  kDlgStrRenameGameTitleTo = 390;
  kDlgStrChangePositionSetup = 391;
  kDlgStrPositionName = 392;
  kDlgStrWhiteToMove = 393;
  kDlgStrWhiteCanPlayOOO = 394;
  kDlgStrWhiteCanPlayOO = 395;
  kDlgStrBlackCanPlayOOO = 396;
  kDlgStrBlackCanPlayOO = 397;  }

  kDlgStrAreYouSureYouWantToSaveThisBoardWithoutAName = 398;

{ kDlgStrCreatingSheet = 399;
  kDlgStrItsPositionCouldNotBeInitialized = 400; }

  kDlgStrPreparingTheDatabase = 401;
  kDlgStrIllegalMoveFoundSheetCreationWillBeStopped = 402;

{ kDlgStrCreatingHeader = 403;  }

  kDlgStrVariationsRecorded = 404;
  kDlgStrVariationAbbreviation = 405;

{ kDlgStrSheetInformation = 406;
  kDlgStrMoveMustBeFromThisMoveTo199 = 407;
  kDlgStrColumnsRangeFrom9To27 = 408;
  kDlgStrPrintersAreEpsonIBMHPToshibaOrNone = 409;
  kDlgStrStartingMoveColumn = 410;
  kDlgStrNumberOfColumns = 411;
  kDlgStrPrinterType = 412;
  kDlgStrBlanksAreNotAllowed = 413;
  kDlgStrNoMoreCharactersCanBeAdded = 414;
  kDlgStrComputerPlaysWhiteYN = 415;
  kDlgStrComputerPlaysTopCandidateYN = 416;
  kDlgStrHideInformationYN = 417;
  kDlgStrAllYesNoFieldsMustBeFilledIn = 418;
  kDlgStrAddThisLineAndRestartYourComputerBeforeTryingAgain = 422; }

  kDlgStrCouldNotSaveAFileInTheAnalystPath1 = 423;
  kDlgStrCouldNotSaveAFileInTheAnalystPath2 = 424;
  kDlgStrCouldNotSaveAFileInTheAnalystPath3 = 425;
  kDlgStrTXTFileExtension = 426;
  kDlgStrCouldNotCreateATemporaryFile = 427;

{ kDlgStrErrorWhenCreatingGraphicsBufferProgramHalted = 428;
  kDlgStrErrorWhenStartingGraphicsProgramHalted = 429; }

  kDlgStrThereWasNotEnoughRAMMemoryToStartDatabaseEngine1 = 430;
  kDlgStrThereWasNotEnoughRAMMemoryToStartDatabaseEngine2 = 431;

{ kDlgStrTheISAMErrorWas = 432;
  kDlgStrTheNumberOfPagesWas = 433;
  kDlgStrErrorWhenSettingDisplay = 434;
  kDlgStrErrorWhenSettingGraphicsMode = 435;
  kDlgStrThePaletteFilePALETTEPCXCouldNotBeFound = 436;
  kDlgStrPressAKeyToContinue = 437; }

  kDlgStrExportStartsBeforeFirstMoveOfVariationChangePreferences = 438;

{ kDlgStrFirstPositionCouldNotBeInitialized = 439; }

  kDlgStrThereWasAProblemOpeningTheExportFileCheckThePath = 440;  
  kDlgStrAnUnsupportedInformantCodeWasDiscovered = 441;
  kDlgStrThereWasAProblemSavingTheBookmark = 442;
  kDlgStrUseFigurines = 443;
  kDlgStrWhiteLetter = 445;
  kDlgStrBlackLetter = 446;
  kDlgStrThisBookDoesNotContainNamedPositions = 447;
  kDlgStrThisBookDoesNotContainRecordedGames = 448;
  kDlgStrThereWasAProblemOpeningThePGNFile = 449;
  kDlgStrThePGNFileWasEmpty = 450;
  kDlgStrThisFileDoesNotExist = 451;
  kDlgStrYouCannotUseTheCandidatesWhileTraining = 452;
  kDlgStrPieceLettersCannotBeBlank = 453;
  kDlgStrPieceLettersMustBeUnique = 454;
  kDlgStrAreYouSureYouWantFactorySettings = 455; 
  kDlgStrNoGameIsHighlighted = 456;
  kDlgStrNewDefaultPreferencesCreated = 457;
  kDlgStrNoPositionNameIsHighlighted = 458;
  kDlgStrAreYouSureYouWantToDeleteTheAssessment = 459;
  kDlgStrThisPositionHasNoNumericAssessment = 460;
  kDlgStrStop = 461;
  kDlgStrDone = 462;
  kDlgStrThereWasAProblemOpeningTheEPDFile = 463;
  kDlgStrTheEPDFileWasEmpty = 464;
  kDlgStrAreYouSureYouWantToEmptyTheEPDFile = 465;
  kDlgStrAnalystFilesWereUpdated = 466; 
  kDlgStrAddingNamedPositions = 467;
  kDlgStrAddingGames = 468;   
  kDlgStrThereWasAProblemOpeningTheLanguageFile = 469;
  kDlgStrTheLanguageFileWasEmpty = 470;
  kDlgStrTheEndingMoveNumberMustBeGreaterThanTheStartingMoveNumber = 471;
  kDlgStrTheStartingMoveNumberIsTooLow = 472;

  kDlgStrThereWasAProblemCreatingTheTrainingFileForThisBook = 473;

  kDlgStrButtonOK = 1900;
  kDlgStrButtonCancel = 1901;
  kDlgStrButtonHelp = 1902;


  {------------------ Other Stuff -------------------}
  kPGNClipboardFileName = 'CLIPBRD.PGN';
  // kLanguageFileName = 'LANGUAGE.BWD';
  // kZarkov3FileName = 'ZARKOV.B8';
  // kTempFootnoteFileName = 'SHEET1.TMP';
  // kHIARCS2FileName = 'B8.B8';
  // kGenius3FileName = 'B8.EPD';
  // kGideonFileName = 'B8.';

  kSQLiteFileExtension = '4MD';
  kSQLiteGameMasterFileExtension = 'GMM';
  kSQLiteGameIndexFileExtension = 'GM4';

  kDefaultFoleyOpponentRepertoireFileName = 'OnlineOpponent.' + kSQLiteFileExtension;  // FIXEDIN build 130

  kMultimediaFolderExtension = '3MM';

  kEbookPreferencesFileExtension = '3PR';  
  // kMainFileExtension         = '4MD';
  {$IFDEF MSWINDOWS}
  kMainFileExtension          = '2MD';
  {$ENDIF}

    {
  kMainFileIndexExtension    = '2MX';
  kMainFileDiaExtension      = '2M$';
  kMainFileMsgExtension      = '2M@'; }

  // kBookmarkMovesExtension    = '2B1';
  // kBookmarkPositionExtension = '2B2';

  kBoardNameExtension        = '2JD';
  kBoardNameIndexExtension   = '2JX';
  kBoardNameDiaExtension     = '2J$';
  kBoardNameMsgExtension     = '2J@';

  // kTrainingExtension         = '2TM';
  // kTrainingIndexExtension    = '2TI';
  // kTrainingDiaExtension      = '2T$';
  // kTrainingMsgExtension      = '2T@';

  // kPositionSetExtension      = '3PS';
  // kPositionSetIndexExtension = '3PI';
  // kPositionSetDiaExtension   = '3P$';
  // kPositionSetMsgExtension   = '3P@';

  // kPGNControlFileExtension   = '2PC';
  // kPGNGameMainFileExtension  = 'GMD';
  // kPGNGameIndexFileExtension = 'GMX';

  kAnalysisBankMainExtension = 'PR1';
  kAnalysisBankIndexExtension = 'PRX';
  kAnalysisBankDiaExtension = 'PR$';
  kJoyOfChessMainFileName = 'JOYOFCHS.' + kAnalysisBankMainExtension;

  kPreferencesTextHeader = 'Chess Openings Wizard Preferences File';
  kBackSolveTemporaryFileNameA = 'BACKSLVA.$$$';
  kBackSolveTemporaryFileNameB = 'BACKSLVB.$$$';

  kGameSearchTemporaryFileName = '$SEARCH$.$$$';

  kExportCommentsNotAtAll = 0;
  kExportCommentsEmbedded = 1;
  kExportCommentsSeparately = 2;

  kExportMovesColumnar = 0;
  kExportMovesParagraph = 1;

  kExportMoveNumbersSpace = 0;
  kExportMoveNumbersPeriod = 1;
  kExportMoveNumbersBoth = 2;

  kASCIIAppend = 0;
  kASCIIErase = 1;

  kEPDAppend = 0;
  kEPDErase = 1;

  kEPDAll = 0;
  kEPDLeaf = 1;
  kEPDCurrent = 2;

  kFontTilburg = 0;
  kFontLinaresSingleBorder = 1;
  kFontLinaresDoubleBorder = 2;
  kFontLinaresSingleAlgebraicBorder = 3;
  kFontLinaresDoubleAlgebraicBorder = 4;
  kFontTASC = 5;
  kFontMeridaSingleBorder = 6;
  kFontMeridaDoubleBorder = 7;
  kFontMeridaSingleAlgebraicBorder = 8;
  kFontMeridaDoubleAlgebraicBorder = 9;

  kMaximumUCIStartupCommands = 20;
  kMaximumWinboardStartupCommands = 20;

  {------------------ GameMaster used in Masterchess -------------------}
  kPlayerNameKeyLength = 30;
  kECOCodeKeyLength = 3;
  kMoveOrderKeyLength = 30;
  kDateKeyLength = 10;
  kRoundLength = 2;
  kResultLength = 7;

  kGameListWindowNumberOfColumns = 6;
  
  kFENImportDoNotNamePositions = 1;
  kFENImportCreateSequentialNames = 2;
  kFENImportUsingWhitePlayerNames = 3;
  kFENImportUsingBlackPlayerNames = 4;
  kFENImportUsingWhiteAndBlackPlayerNames = 5;
  kFENImportUsingFEN = 6;

  kMaximumBoardNameLength = 41;
  // kLEGACYMaximumBoardNameLength = 41;
  kMaximumBoardNameLengthAsAString = '41';

    // FIXEDIN build 67
  kEbookWindowLastPlatformToOpenThisDatabaseIsMacintosh = 1;
  kEbookWindowLastPlatformToOpenThisDatabaseIsWindows = 2;

  kEbookWindowDefaultNormalDifferenceInHeightBetweenWindowsAndMacintosh = 38; // Macintosh windows don't have menus.

  kEbookWindowDefaultNormalWindowHeightForWindows = 682;
  kEbookWindowDefaultNormalWindowHeightForMacintosh =
    kEbookWindowDefaultNormalWindowHeightForWindows - kEbookWindowDefaultNormalDifferenceInHeightBetweenWindowsAndMacintosh;

  kEbookWindowDefaultWindowState = TWindowState.wsNormal;
  kEbookWindowDefaultNormalWindowLeft = 5;
  kEbookWindowDefaultNormalWindowTop = 5;
  kEbookWindowDefaultNormalWindowWidth = 1111;
  {$IFDEF MSWINDOWS}
  kEbookWindowDefaultNormalWindowHeight = kEbookWindowDefaultNormalWindowHeightForWindows;
  {$ENDIF}
  {$IFDEF MACOS}
  kEbookWindowDefaultNormalWindowHeight = kEbookWindowDefaultNormalWindowHeightForMacintosh;
  {$ENDIF}
  kEbookWindowDefaultNormalLeftPanelWidth = 473;           // FIXEDIN build 67
  kEbookWindowDefaultNormalBottomPanelHeight = 413;
  kEbookWindowDefaultNormalPastMovesPanelHeight = 130;
  kEbookWindowDefaultNormalCommentPanelHeight = 135;
  kEbookWindowDefaultNormalEngineRightPanelWidth = 276;
  kEbookWindowDefaultNormalEnginePanelHeight = 102;

  kEbookWindowDefaultFullScreenLeftPanelWidth = 473;        // FIXEDIN build 67
  kEbookWindowDefaultFullScreenBottomPanelHeight = 413;
  kEbookWindowDefaultFullScreenPastMovesPanelHeight = 130;
  kEbookWindowDefaultFullScreenCommentPanelHeight = 135;
  kEbookWindowDefaultFullScreenEngineRightPanelWidth = 276;   // FIXEDIN build 67
  kEbookWindowDefaultFullScreenEnginePanelHeight = 102;       // FIXEDIN build 67

type
  TCopyDiagramGraphicsFormat = (kCopyDiagramPNG, kCopyDiagramBMP, kCopyDiagramJPG);  // FIXEDIN build 187

  Str80 = String[80];
  Str255 = String[255];

  EDatabaseProblem = class (Exception);
  EFileProblem = class (Exception);

  TMultimediaTrack = String;
  TMultimediaType = (kMultimediaTypeUnknown, kMultimediaTypeAudio, kMultimediaTypeVideo);
  TMultimediaFormat = String;
  TMultimediaSourcePlatform = String;

    { Move, diacritic, preferred mark, informant code, backsolve total }
    { Worst case is: 'Nb8xd7+!!*,=>50,000Cabc'   }
  // CandidateNotationType = String[40];
  CandidateNotationType = ShortString;

  TEncodedMoveOrderSearchString = String[240];

  TGMHeader = record
    FirstMoves: String[kMoveOrderKeyLength];
    Event,
    Site,
    WhitePlayerName,
    BlackPlayerName: String[kPlayerNameKeyLength];
    Date: String[kDateKeyLength];
    Round: String[kRoundLength];
    Result: String[kResultLength];
    ECOCode: String[kECOCodeKeyLength];
  end;

    // FIXEDIN build 130
  TFoleyGameSource = (kFoleyGameSourceLichess,
                      kFoleyGameSourceChessDotCom);

  TWhereToPutGames = (kPutGamesInList,
                      kPutGamesInPGNFile,
                      kPutGamesInBothListAndPGNFile);

  TTrainingMode = (kRandom,
                   kRandomCoverage,
                   kSequentialCoverage);

  TTrainingRewindTo = (kTrainingRewindToStartingPosition,
                       kTrainingRewindToWhereTrainingBegan,
                       kTrainingRewindToLastBranch);

  NotationArrayType = array [1..kMaximumPlies] of CandidateNotationType;

  PastBoardsType = array [0..kMaximumPlies] of ChessBoardType;

  RefreshSquarePairType = array [1..2] of SquareType;

  MoveArrayType = array [1..kMaximumPlies] of ChessMoveType;
  UnMoveArrayType = array [1..kMaximumPlies] of TUnMove;

  TExportComments = kExportCommentsNotAtAll..kExportCommentsSeparately;

  TExportMoves = kExportMovesColumnar..kExportMovesParagraph;

  TExportMoveNumbers = kExportMoveNumbersSpace..kExportMoveNumbersBoth;

  TSortCandidatesBy = (kSortCandidatesNotAtAll,
                       kSortCandidatesByInformantRate,
                       kSortCandidatesByNumericAssessment);

  TSortGameMasterTreeCandidatesBy = (kSortMCCandidatesByNumberOfGames,
                                     kSortMCCandidatesByYear,
                                     kSortMCCandidatesByWins,
                                     kSortMCCandidatesByWinsAndDraws);

  TTrainingComputerPlays = kTrainingComputerPlaysWhite..kTrainingComputerPlaysNotAtAll;

  TAfterAnimatingGame = (kAfterAnimatingGameStop,
                         kAfterAnimatingGameRestartGame,
                         kAfterAnimatingGameNextGame);

  TStartBackSolveFrom = (kStartBackSolveFromStartingPosition,
                         kStartBackSolveFromCurrentPosition);

  TStartEPDExportFrom = (kStartEPDExportFromStartingPosition,
                         kStartEPDExportFromCurrentPosition);

  TSelectPositionsStartFrom = (kSelectPositionsFromStartingPosition,
                               kSelectPositionsFromCurrentPosition);

  TSelectPositionsSideToMove = (kSelectOnlyWhiteToMove,
                                kSelectOnlyBlackToMove,
                                kSelectBothWhiteAndBlackToMove);

  TASCIIAppendOrErase = kASCIIAppend..kASCIIErase;

  TEPDAppendOrErase = kEPDAppend..kEPDErase;

  TEPDAllLeaf = kEPDAll..KEPDLeaf;

  TAppendOrErase = (kAppend,
                    kErase);

  TDiagramFontType = kFontTilburg..kFontMeridaDoubleAlgebraicBorder;

  TChessEngineConnectionType = (kChessEngineConnectViaDDE,
                                kChessEngineConnectViaFiles);

  TChessEngineKind = (kChessEngineWinboard,
                      kChessEngineUCI,
                      kChessEngineMacintosh);

  TChessEngineAction = (kChessEngineDoNothing,
                        kChessEngineStart,
                        kChessEngineShutDown,
                        kChessEngineShowWindow,
                        kChessEngineHideWindow);

  {
  TFENNamingInstruction = (kFENImportDoNotNamePositions,
                           kFENImportCreateSequentialNames,
                           kFENImportUsingWhitePlayerNames,
                           kFENImportUsingBlackPlayerNames,
                           kFENImportUsingWhiteAndBlackPlayerNames,
                           kFENImportUsingFEN);
  }

  TNoveltyFinderBasedOn = (kNoveltyFinderBasedOnManualSymbol,
                           kNoveltyFinderBasedOnBacksolvedSymbol,
                           kNoveltyFinderBasedOnEitherSymbol);

  GameResultType = (kGameResultUnknown,
                    kWhiteWon,
                    kBlackWon,
                    kDraw);

  TPreferencesFontRecord = record
    Color : TAlphaColorRec;   // legacy was TColor;
    Name : String [50];
    Size : Integer;
    Style : TFontStyles;
  end;

  TString80 = String[80];

  TColumnWidthArray = array [0..6] of Integer;

  TNoveltyColorMarks = record
    Green,
    Yellow,
    Red: Boolean;
  end;

  TTrainingLoopChoice = (kTrainingLoopChoiceNextVariation,
                         kTrainingLoopChoiceStopTraining,
                         kTrainingLoopChoiceContinueTraining);

  TLoadingLichessLastGameTaskStatus = (kLoadingLichessLastGameTaskStatusIdle,
                                       kLoadingLichessLastGameTaskStatusStarting,
                                       kLoadingLichessLastGameTaskStatusWaiting,
                                       kLoadingLichessLastGameTaskStatusComplete,
                                       kLoadingLichessLastGameTaskStatusFailed);

  TFoleyFunctionLichessGameTaskStatus = (kFoleyFunctionLichessTaskStatusIdle,
                                         kFoleyFunctionLichessTaskStatusStarting,
                                         kFoleyFunctionLichessTaskStatusWaiting,
                                         kFoleyFunctionLichessTaskStatusComplete,
                                         kFoleyFunctionLichessTaskStatusFailed);

  TPositionSetName = String [kMaximumPositionSetNameLength];
  BoardNameType = String [kMaximumBoardNameLength];
  OpeningCodeType = String [kMaximumOpeningCodeLength];

  TProgramPreferencesRecord = record   // FIXEDIN build 124
    CopyDiagramGraphicsFormat: TCopyDiagramGraphicsFormat;  // FIXEDIN build 187
    ExportDiagramShowMessage: Boolean;                        // FIXEDIN build 187
    ExportDiagramFileName: String;                          // FIXEDIN build 187
    ExportDiagramFolder: String;                        // FIXEDIN build 187

    CloudStorageType: Integer; // FIXEDIN build 176

    LichessWhiteRepertoire,
    LichessBlackRepertoire,
    LichessPGNFile: String;
    LichessAddGamesToPGNFile: Boolean;
    LichessHandle: String;

    FoleyPlayingWhite: Boolean;
    FoleyWhiteRepertoire,
    FoleyBlackRepertoire,
    FoleyOnlineOpponentRepertoire,
    FoleyPGNFile: String;
    FoleyAddGamesToPGNFile: Boolean;
    FoleyHandle: String;
    FoleyIncludeBulletGames,
    FoleyIncludeBlitzGames,
    FoleyIncludeRapidGames,
    FoleyIncludeClassicalGames,
    FoleyIncludeCorrespondenceGames,
    FoleyAddNewMovesToRepertoire: Boolean;

    FoleyGameSource: TFoleyGameSource;
    FoleyGameMaximum: Integer;

    DebugBeepForOvercalls: Boolean;

    LogChessEngine: Boolean;

    // Use3DInBookWindow: Boolean;
    // Use3DInGameWindow: Boolean;

    // Diagram2DPreferences: TDiagram2DPreferences;

    RootDataFolder,
    PGNFolder,
    // NalimovFolder,
    BookFolder,
    GameMasterTreeFolder,
    EPDFolder,
    TemporaryFolder: String; // String[255];

    // WhiteAtBottom: Boolean;  Now it's done for each ebook in the ebook's preference file.
    SoundIsOn: Boolean;

    WantsRealTimeBackSolving : Boolean;
    WantsBackSolveInformationDisplayed : Boolean;
    WantsBreadcrumbsDisplayed : Boolean;
    WantsFloatingHintsDisplayed : Boolean;
    WantsEngineAnalysisWindowOpen: Boolean;

    // DatabaseSafety: Boolean;  Now it's done ebook by ebook in their INI files.
    AskForPromotionPiece: Boolean;

    WantsNumericAssessmentsBackSolved : Boolean;
    WantsInformantRatesBackSolved : Boolean;
    WantsAccumulationsBackSolved : Boolean;

    GameMasterTreeFileName: String; // String[255];     // FIXEDIN build 127
    ECOMasterFileName: String; // String[255];     // FIXEDIN build 127

    ASCIIFileName: String; // String[255];     // FIXEDIN build 127
    ASCIIAppendOrErase : TAppendOrErase;
    ASCIIFileExtension : String; // String [3];

    PGNExportFileName: String; // String[255];     // FIXEDIN build 127
    PGNExportAppendOrErase: TAppendOrErase;
    PGNExportExportComments: Boolean;
    PGNExportEvent: String; // String[255];     // FIXEDIN build 127
    PGNExportSite: String; // String[255];     // FIXEDIN build 127
    // PGNExportDate: String[10];   { 09/11/1999 }
    PGNExportDateYear: String[4];   { 1999  or ???? }
    PGNExportDateMonth: String[2];   { 09 }
    PGNExportDateDay: String[2];   { 11 }
    PGNExportRound: String[2];
    PGNExportWhite: String; // String[255];     // FIXEDIN build 127
    PGNExportBlack: String; // String[255];     // FIXEDIN build 127
    PGNExportGameResult: GameResultType;
    PGNExportECO: String; // String[255];     // FIXEDIN build 127


    EPDFileName: String; // String[255];     // FIXEDIN build 127
    EPDAppendOrErase: TAppendOrErase;
    EPDAllLeaf : TEPDAllLeaf;
    EPDReplaceExistingNumericAssessments : Boolean;
    EPDReplaceExistingPVCommentLines : Boolean;
    EPDPositiveCEFavorsWhite : Boolean;
    EPDExportBlankCEsOnly : Boolean;

    EPDBatchExportAppendOrErase: TAppendOrErase;
    EPDBatchExportStartExportFrom: TStartEPDExportFrom;
    EPDBatchExportExportOnlyLeafNodes: Boolean;
    EPDBatchExportExportNamedPositions: Boolean;
    EPDBatchExportDoNotExportPositionsWithNumericAssessments: Boolean;
    EPDBatchExportBeyondMoveNumber: Integer;

    // SelectPositionsFileName: String[200];
    SelectPositionsSetName: TPositionSetName;
    SelectPositionsAppendOrErase: TAppendOrErase;
    SelectPositionsStartFrom: TSelectPositionsStartFrom;
    SelectPositionsSideToMove: TSelectPositionsSideToMove;
    SelectPositionsIgnoreLeafNodes: Boolean;
    SelectPositionsSelectNamedPositions: Boolean;
    SelectPositionsBeyondMove: Integer;
    SelectPositionsUpToMove: Integer;

    SpeedLearningTimeBeforeArrow,
    SpeedLearningTimeAfterArrow,
    SpeedLearningTimeBetweenDiagrams: Integer;

    SpeedLearningSideToMoveAtBottom: Boolean;
    SpeedLearningLoop: Boolean;

    SpeedTestingSideToMoveAtBottom: Boolean;
    SpeedTestingLoop: Boolean;

    Analyst1Path : String; // String[255];     // FIXEDIN build 127
    Analyst2Path : String; // String[255];     // FIXEDIN build 127

    VariationBeginsWithMoveNumber : Integer;

    ExportComments : TExportComments;
    ExportMoves : TExportMoves;
    ExportMoveNumbers : TExportMoveNumbers;
    ExportStartWithWhiteMove : Boolean;
    ExportStartAtMoveNumber,
    ExportStopAtMoveNumber : Integer;
    ExportNumberOfTabsLeftOfMoves,
    ExportNumberofReturnsAfterMoves,
    ExportNumberOfTabsLeftOfDiagram,
    ExportNumberOfReturnsAfterDiagram : Integer;
    ExportWantsFramesOnDiagrams : Boolean;
    ExportDiagramPrefixTagText,
    ExportDiagramPostfixTagText,
    ExportMovesPrefixTagText,
    ExportMovesPostfixTagText,
    ExportCommentsPrefixTagText,
    ExportCommentsPostfixTagText : String; // String[40];     // FIXEDIN build 127

    ImportNumberOfPlies : Integer;
    ImportRecordGamesUsingFirstHeaderLine : Boolean;
    ImportPutGameHeaderInLastPositionComment : Boolean;
    ImportSuppressDuplicateCommentLines : Boolean;

    ImportBookAddNamedPositions : Boolean;
    ImportBookIgnoreRedColorCode,
    ImportBookIgnoreYellowColorCode,
    ImportBookIgnoreGreenColorCode: Boolean;
    ImportBookMaximumPlyDepth: Integer;

    PGNRecordGamesUsingPlayerNames : Boolean;

    NumberOfSecondsToAnimate : Integer;
    AfterAnimatingGame : TAfterAnimatingGame;

    PromotionPiece : PieceType;

    IndicateCaptures : Boolean;
    IndicateChecks : Boolean;
    UseFigurines : Boolean;
    UseFigurinesForAnalysisSheets : Boolean;
    FigurineKingNumber,
    FigurineQueenNumber,
    FigurineRookNumber,
    FigurineBishopNumber,
    FigurineKnightNumber,
    FigurinePawnNumber : Byte;

    KingLetter,
    QueenLetter,
    RookLetter,
    BishopLetter,
    KnightLetter,
    PawnLetter,
    WhiteLetter,
    BlackLetter: Char;    // AnsiChar?

    // SlidingPieceSpeed: Integer;
    SortCandidatesBy: TSortCandidatesBy;
    FavorUnclearOverEquality: Boolean;
    BacksolveNamedPositions: Boolean;
    BacksolveIgnoreUnassessedLeafNodes: Boolean;
    StartSolvingFrom: TStartBackSolveFrom;

    ShowDeleteAudioConfirmationDialog: Boolean;   // FIXEDIN build 137

    TrainingMode: TTrainingMode;

    TrainingShowPastMistakeWarning: Boolean;                    // FIXEDIN build 192

    TrainingRandomComputerPlays: TTrainingComputerPlays;
    TrainingRandomComputerMustPlayTopCandidate,
    TrainingRandomHumanMustPlayTopCandidate,
    TrainingRandomShowNotInTheBookMessage,
    TrainingRandomShowNoMoreCandidatesMessage,
    TrainingRandomHideInformation: Boolean;
    TrainingRandomRewindTo: TTrainingRewindTo;

    TrainingRandomCoverageComputerPlays: TTrainingComputerPlays;
    TrainingRandomCoverageComputerMustPlayTopCandidate,
    TrainingRandomCoverageHumanMustPlayTopCandidate,
    TrainingRandomCoverageShowNotInTheBookMessage,
    TrainingRandomCoverageShowNoMoreCandidatesMessage,
    TrainingRandomCoverageShowTrainingCompleteMessage,
    TrainingRandomCoverageHideInformation: Boolean;
    TrainingRandomCoverageRewindTo: TTrainingRewindTo;
    TrainingRandomCoverageHowManyInARowToComplete: Integer;
    TrainingRandomCoverageFirstTimeCredit: Integer;

    TrainingSequentialCoverageComputerPlays: TTrainingComputerPlays;
    TrainingSequentialCoverageComputerMustPlayTopCandidate,
    TrainingSequentialCoverageHumanMustPlayTopCandidate,
    TrainingSequentialCoverageShowNotInTheBookMessage,
    TrainingSequentialCoverageShowNoMoreCandidatesMessage,
    TrainingSequentialCoverageShowTrainingCompleteMessage,
    TrainingSequentialCoverageHideInformation: Boolean;
    TrainingSequentialCoverageRewindTo: TTrainingRewindTo;
    TrainingSequentialCoverageHowManyInARowToComplete: Integer;
    TrainingSequentialCoverageFirstTimeCredit: Integer;

      // FIXEDIN build 124
    TrainingLimitedByMoves: Boolean;
    TrainingLimitedNumberOfMoves: Integer;
    TrainingShowLimitedReachedMessage: Boolean;

      // FIXEDIN build 183
    TrainingAutomaticallyResetWhenAddingNewCandidate: Boolean;

    CommentFont : TPreferencesFontRecord;

    CandidateFont : TPreferencesFontRecord;

    DiagramFont: TPreferencesFontRecord;
    DiagramFontKind: TDiagramFontType;
    DiagramPrintHorizontalOffset,
    DiagramPrintVerticalOffset: LongInt;

    AnalysisSheetFont: TPreferencesFontRecord;

    PastMovesFontSize: Integer;
    // CommentsFontSize: Integer;

    ChessEngineWinboardFileName,
    ChessEngineUCIFileName: String; // String[255];     // FIXEDIN build 127
    ChessEngineWinboardConnectionType: TChessEngineConnectionType;

    ChessEngineKind: TChessEngineKind;

    ChessEngineSendStartupCommands: Boolean;

    WinboardChessEngineStartupCommands: array [1..kMaximumWinboardStartupCommands] of TString80;
    UCIChessEngineStartupCommands: array [1..kMaximumUCIStartupCommands] of TString80;

    ChessEngineNicknameWinboard,
    ChessEngineNicknameUCI: String; // String[40];     // FIXEDIN build 127

    ChessEngineAppendNodeCount: Boolean;
    // WinboardChessEngineAppendNodeCount: Boolean;
    // UCIChessEngineAppendNodeCount: Boolean;

    ChessEngineEPDMinimumNodesInMillions : LongInt;
    ChessEngineEPDMinimumTime : LongInt;
    ChessEngineEPDMinimumDepth : LongInt;

    DrawEngineMoveArrow: Boolean;                 // FIXEDIN build 140

    InformantRateScoreForWins,
    InformantRateScoreForClearAd,
    InformantRateScoreForSlightAd : Integer;

    LanguageOffset : Word;

    UCIEngineWindowLeft,
    UCIEngineWindowTop,
    UCIEngineWindowWidth,
    UCIEngineWindowHeight: LongInt;

    WinboardEngineWindowLeft,
    WinboardEngineWindowTop,
    WinboardEngineWindowWidth,
    WinboardEngineWindowHeight: LongInt;

    AnalysisBankWindowLeft,
    AnalysisBankWindowTop,
    AnalysisBankWindowWidth,
    AnalysisBankWindowHeight : LongInt;

    AnalysisBankColumnZeroWidth,
    AnalysisBankColumnOneWidth: LongInt;
    AnalysisBankLeftPanelWidth: LongInt;
    AnalysisBankHideWhenNoMatch: Boolean;

    MainWindowState: TWindowState;
    MainWindowLeft,
    MainWindowTop,
    MainWindowWidth,
    MainWindowHeight: LongInt;

    GameListWindowState: TWindowState;
    GameListWindowLeft,
    GameListWindowTop,
    GameListWindowWidth,
    GameListWindowHeight: LongInt;
    GameListWindowColumnWidthArray: TColumnWidthArray;

    GameWindowState: TWindowState;
    GameWindowLeft,
    GameWindowTop,
    GameWindowWidth,
    GameWindowHeight,
        // Game window, left side
    GameWindowLeftPanelWidth,
    GameWindowEnginePanelHeight,
    GameWindowEngineRightPanelWidth,

      // Game window, right side
    GameWindowCommandsPanelHeight,
    GameWindowHeaderMemoHeight,
    GameWindowPastMovesPanelHeight,
    GameWindowCandidatePanelHeight: Integer;

    SortGameMasterTreeCandidatesBy: TSortGameMasterTreeCandidatesBy;

    NoveltyHighlightColors: TNoveltyColorMarks;

    JoyOfChessDatabaseFileName: String; // String[200];     // FIXEDIN build 127

    ShowWelcomeMessage: Boolean;
    UserName: String; // String[60];     // FIXEDIN build 127
    // SerialNumber: String[7];

    // FENImportNamingInstruction: TFENNamingInstruction;
    FENImportNamingInstruction: Integer;
    FENImportStartingSequentialName: String; // String[kMaximumBoardNameLength - 4];  // room for -001    // FIXEDIN build 127
    FENImportStartingSequentialNumber: Integer;
    FENImportDoNotOverwriteExistingNames: Boolean;

    NoveltyFinderWhiteWinsHighNOLONGERUSED,              // FIXEDIN build 159
    NoveltyFinderWhiteWinsLow,

    NoveltyFinderWhiteClearAdHighNOLONGERUSED,              // FIXEDIN build 159
    NoveltyFinderWhiteClearAdLow,

    NoveltyFinderWhiteSlightAdHighNOLONGERUSED,              // FIXEDIN build 159
    NoveltyFinderWhiteSlightAdLow,

    NoveltyFinderEqualHigh,
    NoveltyFinderEqualLow,

    NoveltyFinderUnclearHigh,
    NoveltyFinderUnclearLow,

    NoveltyFinderWithCompensationHigh,
    NoveltyFinderWithCompensationLow,

    NoveltyFinderLoopHigh,
    NoveltyFinderLoopLow,

    NoveltyFinderBlackWinsHighNOLONGERUSED,              // FIXEDIN build 159
    NoveltyFinderBlackWinsLow,

    NoveltyFinderBlackClearAdHighNOLONGERUSED,              // FIXEDIN build 159
    NoveltyFinderBlackClearAdLow,

    NoveltyFinderBlackSlightAdHighNOLONGERUSED,              // FIXEDIN build 159
    NoveltyFinderBlackSlightAdLow: Integer;

    NoveltyFinderStartingSequentialName: String; // String[kMaximumBoardNameLength - 4];  // room for -001   // FIXEDIN build 127
    NoveltyFinderStartingSequentialNumber: Integer;
    NoveltyFinderDoNotOverwriteExistingNames: Boolean;
    NoveltyFinderMaximumNovelties: Integer;

    NoveltyFinderBasedOn: TNoveltyFinderBasedOn;
    NoveltyFinderLeafNodesOnly: Boolean;

    LeafNodeFinderOnlyWithoutAssessment: Boolean;
    LeafNodeFinderOnlyWithoutInformantRate: Boolean;
    LeafNodeFinderStartingSequentialName: String; // String[kMaximumBoardNameLength - 4];  // room for -001    // FIXEDIN build 127
    LeafNodeFinderStartingSequentialNumber: Integer;
    LeafNodeFinderDoNotOverwriteExistingNames: Boolean;
    LeafNodeFinderMaximumPositions: Integer;

    ShowMissingInstallerSettingsMessage: Boolean;
    ShowICCMessageDuringStartup: Boolean;
    ShowInstallSampleEbooksMessageDuringStartup: Boolean;   // FIXEDIN build 140  used to be just Macintosh
    OfferToCopyOlderEbooksDuringStartup: Boolean;           // FIXEDIN build 141

    UseECOMasterDescriptions: Boolean;

    ShowInterbookTranspositions: Boolean;

    SentinelValue: LongWord;
  end;



  BackSolveTotalType = Word;

  NumericAssessmentType = SmallInt;
  WorkSpaceType = Word;

  InformantRateType = (kWhiteIsWinning,             // FIXEDIN build 159
                       kWhiteClearAdvantage,        // FIXEDIN build 159
                       kWhiteSlightAdvantage,       // FIXEDIN build 159
                       kEqual,
                       kUnclear,
                       kWithCompensation,
                       kBlackSlightAdvantage,       // FIXEDIN build 159
                       kBlackClearAdvantage,        // FIXEDIN build 159
                       kBlackIsWinning,             // FIXEDIN build 159
                       kNoRate,
                       kLoop);

  {      Certainty is currently set from zero to 5.
  TCertainty = (kCertaintyHigh,
                kCertaintyModerate,
                kCertaintySmall,
                kCertaintyNone);
  }

  TCandidateColorMark = (kMarkGreen,
                         kMarkYellow,
                         kMarkRed);

  TWatchPGNGamesToImport = (kImportWhiteAndBlackGames,
                            kImportWhiteGamesOnly,
                            kImportBlackGamesOnly);

  TCandidateRecord = record
    Move: ChessMoveType;
    Notation: CandidateNotationType;
    Rate: InformantRateType;
    TotalPositions: BackSolveTotalType;
    NumericAssessment: NumericAssessmentType;
    GreenHighlight,
    YellowHighlight,
    RedHighlight: Boolean;
    TrainingHowManyInARowCorrect: Integer;
    TrainingCompleted: Boolean;                  // FIXEDIN build 192
    GameMasterWhiteWins,
    GameMasterBlackWins,
    GameMasterDraws: Integer;
    GameMasterLatestYear: Word;
    InLoadedGame,
    InComparisonEbook,
    InComparisonEbookFirstCandidate: Boolean;  // FIXEDIN build 130
  end;

  TCandidateArray = Array [1..kMaximumCandidates] of TCandidateRecord;  
  TUnCandidateArray = Array [1..kMaximumUncandidates] of TUnMove;

  BatchBackSolveNodeRecord = record
    Board: ChessBoardType;
    NumberOfCandidates: Byte;
    NumberOfCandidatesResearched: Byte;
  end;

  BatchBackSolveNodeArrayType = array [0..kMaximumPlies] of BatchBackSolveNodeRecord;

  GameRecordType = record
    Loaded : Boolean;
    InitialBoard : ChessBoardType;
    NumberOfMoves : Integer;
    Moves : MoveArrayType;
  end;


  TPGNHeader = record
    Event,
    Site,
    // Date,
    DateYear,
    DateMonth,
    DateDay,
    Round,
    WhitePlayerName,
    BlackPlayerName,
    ECO,
    FEN: String;
    Result: GameResultType;
  end;


  TWatchPGNFileRecord = Record
    SourceFile,
    TargetFile,
    TargetBook: Str255;
    GamesToImport: TWatchPGNGamesToImport;
    PlayerName: Str80;
  end;
  PWatchPGNFileRecord = ^TWatchPGNFileRecord;



const
  kNoNumericAssessment = NumericAssessmentType(-32768);   // -32768?
  // kNoNumericAssessment = -32768;



implementation



end.
 