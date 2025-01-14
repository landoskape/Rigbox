# Changelog

This file contains a curated, chronologically ordered list of notable changes made to the master branch since the release of Rigbox 2.2.0. Each bullet point in the list is followed by the accompanying commit hash, and the date of the commit. The versioning numbering used is [SemVer](http://semver.org/). This changelog is based on [keep a changelog](https://keepachangelog.com).

## [Most Recent Commits](https://github.com/cortex-lab/Rigbox/commits/master) [2.6.5]

- HOTFIX: Alyx-MATLAB update
- HOTFIX: Corrected typo in obj2struct

## [2.6.4]

- HOTFIX: Alyx-MATLAB update

## [2.6.3]

- HOTFIX: Test fix in signals repo

## [2.6.2]

- PATCH: Scrubbed repository of old files.  Slimmed down from >>100MB to < 5KB
- HOTFIX: Tests fix in signals repo
- HOTFIX: Corrected compatible MATLAB versions in documentation (not compatible with >2019b)

## [2.6.0]

- A huge amount of refactoring, especially of the expServer; new tests and documentation
- Experiments can now be started by calling expServer with an expRef.
- Command output type now matches input type in git.runCmd
- Fixed value unassigned error when no lag in `asyncFlipEnd`
- Fixed uniform output error when inputs non-scalar in `namedArg` function
- Fixed uniform output error when default value a cell or string in `pick` function
- Input arg 'field' may now be a string array in `getOr` function
- Informative error thrown if PsychToolbox is likely not set up
- Removed unnecessary cellfun call in dat.listSubjects
- More informative error messages and IDs; now local exp folder is removed if remote folder creation fails
- Zeroing of input devices now happens during initialization in signals, closer to experiment start
- The RigName property is now used in SignalsExp, in line with exp.Experiment behaviour
- The update day may now be a char, cellstr, or string array, and the 'updateSchedule' field of |dat.paths| may be set to -1/'never' to turn off updates
- Pressing 'h' key in expServer will display the keyboard shortcuts.  
- The calibration plot will now be displayed on the screen.
- Stimulus window background colour can now be set with a 'bgColor' field in the parameter struct
- New +git functions display Rigbox versions and allow you to switch between them
- Warning instead of error when no stereo output device found in eui.SignalsTest
- exp.Parameters class has been fully documented and some code refactored `4d3f3f2` 2020-02-03
- there is now more informative error message in the hw.ptb.Window contructor, reminding users to install PTB `a251845` 2020-02-03
- a test was added for the 'distribute' function `92e5a40` 2020-02-03 
- hw.findDevice was renamed to hw.testAudioOutputDevices and documentation regarding this function was added to hardware_config `244e93c` 2020-02-03
- refactoring of hw.devices, including documentation, use of 'useDaq' flag and choosing lowest latancy audio device by default `477b4e8` 2020-02-03
- fixed typo in calibration_test that meant parameter default was used `d58408e` 2020-02-03
- removed redundant cellfun call in dat.listSubjects and brought dat.newExp back in line with Alyx.newExp `ee35ed3` 2020-02-14
- zeroing of devices in exp.SignalsExp now occurs within init, in line with exp.Experiment `3ba222f` 2020-03-13

## [2.5.0]

- new alyx instance now requested robustly when not logged in during SignalsExp
- expStop event now logged has missing value when last trial over, even when expStop defined in def fun
- tests for SignalsExp class
- alyx warnings not thrown when database url not defined `b023187`, `cbad678`
- new SignalsExp test GUI has numerous bugfixes and allows you to view exp panel `ad52845` 2019-11-14
- exp.trialConditions allows trial reset, similar to ConditionServer `62eb9ac` 2019-11-14
- fix for catastrophic crash when stimulus layers contain empty values
- time signal now always updates before expStart event `cab5a2f` 2019-11-01
- ability to hide event updates in the ExpPanel `fef6ac2` 2019-11-14
- updates to documentation including folder READMEs and Contents files `07cb30e`, `d2b2189`, `3f3f869`
- added utils for changing scale port and audio device `139d770` 2019-11-22
- bugfix for failing to save signals on error `d6d9289` 2019-11-24
- cleaned up older code `b89a0c1`, `d6b23c1`
- scale port cleaned up upon errors `f19cec4` 2019-11-27
- added flags to addRigboxPaths `10dc661` 2020-01-17
- improvements to experiment panels including ability to hide info fields `169fbb4` 2019-11-27
- added guide to creating custom ExpPanels `90294dd` 2019-12-18
- correct behaviour when listening to already running experiments `32a2a17` 2019-12-18
- added support for remote error ids in srv.StimulusControl `9d31eea` 2019-11-27
- added tests for eui.ExpPanel `572463c` 2020-01-28
- added tests for *paramProfile functions + no error when saving into new repo `72b04fa` 2020-01-30
- added FormatLabels flag to eui.SignalsExpPanel `c5794a8` 2020-02-03
- HOTFIX Bugfix in signals for versions >2016b & <2018b

## [2.4.1](https://github.com/cortex-lab/Rigbox/releases/tag/2.4.0)

- patch to readme linking to most up-to-date documentation `4ff1a21` 2019-09-16
- updates to `+git` package and its tests `5841dd6` 2019-09-24
- full test coverage for expServer `635aca2` 2019-10-02
- function for creating mock rig structure `f32a0fe` 2019-10-02
- disregardTimelineInputs rig hardware field no longer valid `c3bc046` 2019-10-02
- added a test for structAssign `2213b18` 2019-10-02
- bug fix for updating alyx instance on quit `635aca2` 2019-10-02
- more documentation 
- print text to screen during calibration `facaef4` 2019-10-02
- supressing plots during calibration; task bar no longer visible `aad3a17` 2019-10-02
- no hardware info registration warning if databaseURL path not defined `4b8b28c` 2019-10-02
- better organization of expServer `f32a0fe` 2019-10-02
- bug fix for rounding negative numbers in AlyxPanel `31641f1` 2019-10-17
- stricter and more accurate tolerance in AlyxPanel_test `31641f1` 2019-10-17
- added tests for dat.mpepMessageParse and tl.bindMpepServer `bd15b95` 2019-10-21
- HOTFIX to error when plotting supressed in Window calibrate `7d6b601` 2019-11-15
- updates to alyx-matlab submodule 2019-11-02

## [2.3.1](https://github.com/cortex-lab/Rigbox/releases/tag/2.3.1)

- patch in alyx-matlab submodule 2019-07-25
- updated Signals performance test `993d906` 2019-07-19
- fixes to tests for the Alyx Panel `eb5e9b9` 2019-07-19
- added tests for most used burgbox functions `` 2019-08
- documentation added for numerous functions `661450`, `de0dc9` 2019-08-11
- removed +dat/parseAlyxInstance.m `1939b2` 2019-08-08
- fix for large json hardware arrays (issue #168) `058001`
- fix for checking functions on path in newer versions `c4022d` 2019-08-09
- fix for chrono wiringInfo in Timeline `fdfe72` 2019-08-11
- fixes to burgbox utils `cf3c384`, `bb5c3f7`, `9be079`, `de0dc92`
- added utility for checking test coverage `efa7414` 2019-08-08
- added walkthroughs for parameters and timeline 2019-08-14
- improvements to water expServer calibration function `dd0adb7` 2019-08-14
- updates to signals submodule `f760e5e` 2019-09-03

## [2.2.1](https://github.com/cortex-lab/Rigbox/releases/tag/v2.2.1)
