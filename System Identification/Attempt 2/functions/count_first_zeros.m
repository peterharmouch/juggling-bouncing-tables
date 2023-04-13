function num_zeros = count_first_zeros(arr)
% arr is the input array

% Finding the index of the first occurrence of 1
first_one = find(arr==1, 1);

if arr(1) == 0
    if isempty(first_one) % if no 1 is found
        num_zeros = length(arr);
    else
        num_zeros = first_one - 1;
    end
else % If the array doesn't start with 0s
    num_zeros = 0;
end
