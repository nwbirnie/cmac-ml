%Returns a list of tile indices which are activated.
%
%Inputs:
%  variables: a vector of double precision floating point, specifying the
%             coordinates for which to return the activated tile indices.
%
%  numTilings: the number of tilings to overlay on the space, which should
%              be a power of two.
%
%              It is possible to compute the number of tilings as a
%              function of generalisation resolution (see:
%              http://webdocs.cs.ualberta.ca/~sutton/tiles.html).
%
%  memorySize: the total number of memory slots available (which may be the
%              total number of tiles).
%
%Outputs:
%  tiles: the tile indices activated by the prodided variables array.

function tiles = getTiles(variables, numTilings, memorySize)
if ~isvector(variables)
    error('variables must be a vector');
end
if ~isscalar(numTilings) || numTilings < 0 || numTilings - floor(numTilings) ~= 0
    error('numTilings must be a positive integer');
end
if ~isscalar(memorySize) || memorySize < 2048 || memorySize - floor(memorySize) ~= 0
    error('memorySize must be a positive integer, greater than 2047');
end
if log(numTilings) / log(2) - abs(log(numTilings) / log(2)) - 1e-15 > 0
    warning('getTiles:warn','numTilings should be a power of 2');
end

numVariables = numel(variables);
quantisedState = floor(variables .* numTilings);
offsets = zeros(numel(quantisedState),1);
tiles = zeros(numTilings,1);
coordinates = zeros(numVariables + 1,1);

for i=1:numTilings
    for j=1:numVariables
        if (quantisedState(j) >= offsets(j))
            coordinates(j) = quantisedState(j) - mod(quantisedState(j) - offsets(j), numTilings);
        else
            coordinates(j) = quantisedState(j) + 1 + mod(offsets(j) - quantisedState(j) - 1, numTilings) - numTilings;
        end
        offsets(j) = offsets(j) + 1 + 2 * i;
    end
    coordinates(numVariables + 1) = j;
    tiles(i) = hashCoordinates(coordinates,memorySize);
end
end

function index = hashCoordinates(coordinates,memorySize)
global getTiles__firstCall__;
global getTiles__rndseq__;

if ~islogical(getTiles__firstCall__) || ~getTiles__firstCall__
    getTiles__rndseq__ = randi([intmin intmax]);
    getTiles__firstCall__ = true;
end

numCoordinates = numel(coordinates);
sum = 0;
for i=1:numCoordinates
    index = mod(coordinates(i) + 449 * i,2048);
    while index < 1
        index = index + 2048;
    end
    sum = sum + getTiles__rndseq__(floor(index));
end
index = floor(mod(sum,memorySize));
while index < 1
    index = index + memorySize;
end
end