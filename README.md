﻿﻿--------------------------------------------------------------------
********************************************************************
--------------------------------------------------------------------

## TABLE OF CONTENTS <a name="table-of-contents"></a>
1. [TABLE OF CONTENTS ](#table-of-contents-)
2. [CONTACT](#contact)
3. [SCOPE OF THE IMPORT ](#scope-of-the-import-)
4. [GET STARTED ](#get-started-)
5. [EXPORT OF .STEP FILES FROM CAD](#export-of-step-files-from-cad)
	1. [EXPORT WITH RHINO 7 ](#export-with-rhino-7-)
6. [PROVIDED FUNCTIONS ](#provided-functions-)
7. [PROBLEMS WITH YOUR IMPORT ](#problems-with-your-import-)
--------------------------------------------------------------------
********************************************************************
--------------------------------------------------------------------

## CONTACT
This code was developed to help our research at the Institut für Mechanik und Statik of the Universität der Bundeswehr München. The functionality of the code is of course 
at the moment limited because its purpose is to deal with geometries, we are currently interested in. However, it can be extended to cover a wider variety. In the case that 
your geometry cannot be imported, you can contact me under "michael.loibl@unibw.de" and we can discuss whether I can provide an update.

[<div style="text-align: right">Back to the top</div>](#table-of-contents)

------------------------------

## SCOPE OF THE IMPORT <a name="scope"></a>
The import is written for multipatch trimmed NURBS surface geometries. It is used for the definition of trimmed patches in the context of the Isogeometric Analysis (IGA) 
which is a subgroup of FEM using NURBS as basis functions.

[<div style="text-align: right">Back to the top</div>](#table-of-contents)

------------------------------

## GET STARTED <a name="start"></a>
The easiest way to get used to the code is to start with the script "test_step_import.m". Plotting functions are illustrating your import and help to check whether the import worked correctly. A set of really simple geometries is provided - they start with "geometry_". The import was also tested for more complex geometries. However, these files cannot be provided due to licensing reasons. In order to import a new geometry, you can simply change the jobname which defines the name of your .step file. You see automatically plots in the parametric and physical space. Thereby, you can easily check whether your import worked correctly. You can change the resolution of the plots:

	resolution_param = 10;	% resolution of trimming curves in the parametric space
	resolution_phys.surf = 2;	% resolution of surface in the physical space
	resolution_phys.curv = 10;	%resolution of curve in the physical space

[<div style="text-align: right">Back to the top</div>](#table-of-contents)

------------------------------

## EXPORT OF .STEP FILES FROM CAD
The generation of .step files was performed and tested with the following CAD programs:
- Rhino 7

[<div style="text-align: right">Back to the top</div>](#table-of-contents)

------------------------------

### EXPORT WITH RHINO 7 <a name="export_rhino"></a>

The following settings are selected throughout the export:
- AP214AutomativeDesign format
- parametric curves export (this is important for trimming because it is easier to handle the trimming curve embedded in the patch; the physical curve is exported anyway; 
the here documented import function only works if the parametric curve is part of the .step file)

[<div style="text-align: right">Back to the top</div>](#table-of-contents)

------------------------------

## PROVIDED FUNCTIONS <a name="functions"></a>
The important contribution is the "import_STEP.m" function in combination with the class definitions. The other functions are simply visualization tools to check whether the import worked properly. The functions are copied from another code and are not changed. Some of them are duplicates with only slightly changed inputs (this is not nice, but also nothing to care about in this context).

[<div style="text-align: right">Back to the top</div>](#table-of-contents)

------------------------------

## PROBLEMS WITH YOUR IMPORT <a name="functions"></a>
In case your geometry cannot be imported but is a NURBS surface, please contact me. I can try to extend the import function for your geometry.

[<div style="text-align: right">Back to the top</div>](#table-of-contents)