function [listOfPossibleHolos convertedSequence] = convertSequence(sequence);

[listOfPossibleHolos idx idx2] = uniquecell(sequence);

convertedSequence=idx2;
%save('\\128.32.173.33\Imaging\STIM\Calibration SLM Computer\SEQUENCE_data.mat','sequence');
%save('\\128.32.173.33\Imaging\STIM\Calibration SLM Computer\listOfPossibleHolos.mat','listOfPossibleHolos');