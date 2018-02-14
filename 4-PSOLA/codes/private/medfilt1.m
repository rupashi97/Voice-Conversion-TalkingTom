function y = medfilt1(x,n,blksz,DIM)

% Validate number of input arguments
error(nargchk(1,4,nargin));
if nargin < 2, n = []; end
if nargin < 3, blksz = []; end
if nargin < 4, DIM = []; end

% Check if the input arguments are valid
if isempty(n)
  n = 3;
end

if ~isempty(DIM) && DIM > ndims(x)
	error('Dimension specified exceeds the dimensions of X.')
end

% Reshape x into the right dimension.
if isempty(DIM)
	% Work along the first non-singleton dimension
	[x, nshifts] = shiftdim(x);
else
	% Put DIM in the first (row) dimension (this matches the order 
	% that the built-in filter function uses)
	perm = [DIM,1:DIM-1,DIM+1:ndims(x)];
	x = permute(x,perm);
end

% Verify that the block size is valid.
siz = size(x);
if isempty(blksz),
	blksz = siz(1); % siz(1) is the number of rows of x (default)
else
	blksz = blksz(:);
end

% Initialize y with the correct dimension
y = zeros(siz); 

% Call medfilt1D (vector)
for i = 1:prod(siz(2:end)),
	y(:,i) = medfilt1D(x(:,i),n,blksz);
end

% Convert y to the original shape of x
if isempty(DIM)
	y = shiftdim(y, -nshifts);
else
	y = ipermute(y,perm);
end


%-------------------------------------------------------------------
%                       Local Function
%-------------------------------------------------------------------
function y = medfilt1D(x,n,blksz)
%MEDFILT1D  One dimensional median filter.
%
% Inputs:
%   x     - vector
%   n     - order of the filter
%   blksz - block size

nx = length(x);
if rem(n,2)~=1    % n even
    m = n/2;
else
    m = (n-1)/2;
end
X = [zeros(m,1); x; zeros(m,1)];
y = zeros(nx,1);

% Work in chunks to save memory
indr = (0:n-1)';
indc = 1:nx;
for i=1:blksz:nx
    ind = indc(ones(1,n),i:min(i+blksz-1,nx)) + ...
          indr(:,ones(1,min(i+blksz-1,nx)-i+1));
    xx = reshape(X(ind),n,min(i+blksz-1,nx)-i+1);
    y(i:min(i+blksz-1,nx)) = median(xx,1);
end
