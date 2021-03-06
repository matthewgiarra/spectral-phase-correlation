% This class represents phase residues for 2-D phase unwrapping.
% For details, see Chapter 4 of the book "Two-dimensional phase unwrapping"
% by Ghiglia and Pritt
classdef PhaseResidue
    properties
        % True if positive residue, false if not positive residue.
        positive_residue = false;
        
        % True if negative residue, false if not negative residue.
        negative_residue = false;
        
        % True if the pixel lies on a branch cut, false if not.
        branch_cut = false;
        
        % True if the pixel lies on the image border, false if not.
        image_border = false;
        
        % True if the pixel represents a balanced residue, false if not.
        balanced_residue = false;

        % True if the pixel represnts an "active residue," i.e.
        % if the pixel is "connected to the current set of branch cuts."
        % I think this means that the pixel is on a branch cut within
        % an active search window.
        active_residue = false;

        % True if the pixel has been unwrapped, false if not.
        unwrapped_pixel = false;
    end
    
    % This section defines the methods for PhaseResidue.
    methods
        
        % This method initializes a PhaseResidue object, i.e., 
        % sets all its fields to false. The point of doing this
        % was to try to avoid re-creating arrays of 
        % these objects, and just create an array once
        % and re-initialize it each time it's re-used.
        % However this turned out to be just about as slow.
        function obj = init(obj)
            obj.positive_residue = false;
            obj.negative_residue = false;
            obj.branch_cut = false;
            obj.image_border = false;
            obj.balanced_residue = false;
            obj.active_residue = false;
            obj.unwrapped_pixel = false;
        end
    end
end








