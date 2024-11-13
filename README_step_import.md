﻿﻿--------------------------------------------------------------------
********************************************************************
--------------------------------------------------------------------

## TABLE OF CONTENTS <a name="table-of-contents"></a>
1. [CONTACT](#contact)
1. [SCOPE OF THE IMPORT](#scope)
2. [EXPORT OF .STEP FILES FROM CAD](#export)
    1. [EXPORT WITH RHINO 7](#export_rhino)
3. [HOW TO START](#start)
4. [PROVIDED FUNCTIONS](#functions)
--------------------------------------------------------------------
********************************************************************
--------------------------------------------------------------------

## CONTACT {#contact}
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

## EXPORT OF .STEP FILES FROM CAD {#export}
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

### HOW TO START <a name="start"></a>
Place new .step files in the folder "stp_geometries" or start with one of the existing geometries. The easiest way to get used to the code is to start with the script "test_step_import.m". 
In order to import a new geometry, you can simply change the jobname which defines the name of your .step file. You see automatically plots in the parametric and physical space. Thereby, 
you can easily check whether your import worked correctly. You can change the resolution of the plots:

	resolution_param = resolution of trimming curves in the parametric space
	resolution_phys.surf = resolution of surface in the physical space
	resolution_phys.curv = resolution of curve in the physical space

A set of really simple geometries can be found in the folder stp_geometries. The import was also tested for more complex geometries. However, these cannot be provided due to
licensing reasons.

[<div style="text-align: right">Back to the top</div>](#table-of-contents)

------------------------------

## PROVIDED FUNCTIONS <a name="functions"></a>
The important contribution is the "import_STEP.m" function in combination with the class definitions in the folder "class_def". The other functions in the folders "NURBS_functions" and 
"plotting" are simply visualization tools to check whether the import worked properly. The functions in the folder "NURBS_functions" are copied from another code and are not changed.
Some of them are duplicates with only slightly changed inputs (this is not nice, but also nothing to care about in this context).

[<div style="text-align: right">Back to the top</div>](#table-of-contents)