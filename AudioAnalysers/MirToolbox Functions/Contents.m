% MIRtoolbox
% Version 1.3.4 (Matlab Central version) 14-December-2011
%
% A more detailed documentation of each function is available using the
% help command. For instance, type help miraudio.
%
% A complete documentation is available in the downloaded folder and online.
%			http://www.jyu.fi/music/coe/materials/mirtoolbox
%
%BASIC AUDIO OPERATIONS
% miraudio         - Loads and return waveform
% mirframe         - Decomposes into successive frames
% mirsegment       - Decomposes into successive segments
% mirlength        - Temporal length
%
%DATA OUTPUT
% mirgetdata       - Return result as a Matlab standard structure
% mirsave          - Save audio and other temporal data into audio files
% mirexport        - Export the analytical results to a text file
% mirplay          - Plays audio and other temporal data
%
%ANALYTICAL OPERATORS
% mirspectrum      - FFT spectrum with many post-processing operations
% mirautocor       - Autocorrelation function
% mirfilterbank    - Decomposes into channels via a bank of filters
% mirsum           - Sums the channels of a filterbank
%
%DYNAMIC
% mirrms           - Root mean square energy
% mirlowenergy     - Number of frames with lower than average energy
% mirenvelope      - Amplitude envelope (global shape of the waveform)
% mironsets        - Note onset positions and characteristics
% mirattacktime    - Duration of note attacks
% mirattackslope   - Average slope of note attacks
% mireventdensity  - Average frequency of events
%
%RHYTHM
% mirtempo         - Tempo (in beats per minute)
% mirfluctuation   - Fluctuation strength (periodicities in each channel)
% mirbeatspectrum  - Beat spectrum, characterizing the rhythmic content
% mirpulseclarity  - Rhythmic clarity, i.e., beat strength
%
%TIMBRE
% mirbrightness    - Spectral brightness (high-frequency rate)
% mirrolloff       - Spectral rolloff (frequency above which is located a 
%                       certain amount of energy)
% mirmfcc          - Mel-frequency cepstrum coefficients
%                       (numerical description of the spectrum envelope)
% mirinharmonicity - Inharmonicity (partials non-multiple of fundamental)
% mirroughness     - Roughness (sensory dissonance)
% mirregularity    - Spectrum irregularity (amplitude variability of 
%                        successive peaks)
%
%PITCH
% mirpitch         - Pitch frequencies
% mircepstrum      - Cepstrum representation (showing periodicities)
% mirmidi          - Attempts a conversion of audio into MIDI
%
%TONALITY
% mirchromagram    - Chromagram (distribution of energy along pitches)
% mirkeystrength   - Key strengths (probability of key candidates)
% mirkey           - Best keys and modes (in the 12 tone system)
% mirkeysom        - Visualizes key strengths with self-organizing map
% mirmode          - General estimation of mode (major/minor)
% mirtonalcentroid - Tonal centroid (using circles of fifths and thirds)
% mirhcdf          - Harmonic Change Detection Function
%
%PREDICTIONS
% miremotion       - Emotion, represented both as classes and dimensions
%
%ANALYSIS
% mirmean          - Returns the mean of any feature
% mirstd           - Returns the standard deviation of any feature
% mirstat          - Returns statistics of any feature
% mirpeaks         - Peaks
% mirhisto         - Histogram
% mirentropy       - Entropy
% mirzerocross     - Sign-changes ratio
% mircentroid      - Centroid (center of gravity)
% mirspread        - Spread (non-concentration)
% mirskewness      - Skewness (lack of symmetry)
% mirkurtosis      - Kurtosis (peakiness)
% mirflatness      - Flatness
%
%SIMILARITY
% mirflux          - Flux, i.e., distance between successive frames
% mirsimatrix      - Similarity matrix
% mirnovelty       - Novelty score
% mirdist          - Distance between audio files
% mirquery         - Query by example
%
%OTHER
% mirclassify      - Classifies audio sequences
% mircluster       - Clusters segments or frames
% mirfeatures      - Compute a large range of features
% mirmap           - Performs statistical mapping
%
%MATLAB FUNCTIONS generalized to the MIRtoolbox data
% +                - Superposes audio files
% *                - Combines autocor, cepstrum curves
% corrcoef         - Computes correlation between curves
%
%PREFERENCES
% mirchunklim      - Get or set the chunk size threshold
% mirwaitbar       - Toggles on/off the display of progress bars
% mirverbose       - Toggles on/off the display of ongoing operations
% mirparallel      - Toggles on/off parallel processing
