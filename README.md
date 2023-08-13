# DICOMTree

A little Julia package for visualizing DICOM file metadata in the form of a tree. The main function is the Tree function, which is simply a dispatch of the eponymous function in the Term.jl package to the DICOMData type in the DICOM.jl package. 
The package have been tested with CT Scanner, RTDose and RTStruct files. 

## Documentation & installation

Install with:
```
julia> ]  # enters the pkg interface
pkg> add DICOMTree
```

## How to use DICOMTree.jl ?

```julia
using DICOM
using DICOMTree

dcm_file = dcm_parse(dcm_path)

Tree(dcm_file, with_keys = false, maxdepth = 2)
```
Output (with colours in the REPL) : 

```
PatientID
  ├─ StructureSetName ⇒ ART: Unapproved
  ├─ StudyDate ⇒ 20180802
  ├─ StructureSetROISequence ⇒ Vector of DICOMData
  │                              └─ Length ⇒ 46
  │
  ├─ SeriesInstanceUID ⇒ 1.2.276
  ├─ MediaStorageSOPClassUID ⇒ 1.2.840
  ├─ SoftwareVersions ⇒ v1.0
  ├─ ImplementationVersionName ⇒ OFFIS_DCMTK_364
  ├─ Modality ⇒ RTSTRUCT
  ├─ PatientName ⇒ xxx
  ├─ OperatorsName ⇒ xxx
  ├─ ApprovalStatus ⇒ UNAPPROVED
  ├─ InstitutionName ⇒ Any[]
  │
  ├─ ReferencedFrameOfReferenceSequence ⇒ Vector of DICOMData
  │                                         └─ Length ⇒ 1
  │
  ├─ SOPInstanceUID ⇒ 1.2.276
  ├─ SpecificCharacterSet ⇒ ISO_IR 100
  ├─ PatientID ⇒ xxx
  ├─ ImplementationClassUID ⇒ 1.2.276
  ├─ StudyTime ⇒ xxx
  ├─ StructureSetTime ⇒ 123456
  ├─ StudyDescription ⇒ Brain
  ├─ ROIContourSequence ⇒ Vector of DICOMData
  │                         └─ Length ⇒ 46
  │
  ├─ ReviewTime ⇒ Any[]
  │
  ├─ StudyID ⇒ 123456
  ├─ SeriesNumber ⇒ 1
  ├─ SOPClassUID ⇒ 1.2.840
  ├─ StudyInstanceUID ⇒ 1.2.826
  ├─ TransferSyntaxUID ⇒ 1.2.840
  ├─ AccessionNumber ⇒ Any[]
  │
  ├─ StructureSetDate ⇒ 12345678
  ├─ ManufacturerModelName ⇒ xxx
  ├─ PatientSex ⇒ Any[]
  │
  ├─ InstanceNumber ⇒ 1
  ├─ FileMetaInformationGroupLength ⇒ 202
  ├─ ReferringPhysicianName ⇒ Unspecified
  ├─ Manufacturer ⇒ TheraPanacea
  ├─ ReviewDate ⇒ Any[]
  │
  ├─ InstanceCreationTime ⇒ 123456
  ├─ FileMetaInformationVersion ⇒ UInt8[0x00, 0x01]
  │
  ├─ RTROIObservationsSequence ⇒ Vector of DICOMData
  │                                └─ Length ⇒ 46
  │
  ├─ MediaStorageSOPInstanceUID ⇒ 1.2.276
  ├─ StructureSetLabel ⇒ ART: Unapproved
  ├─ SeriesDescription ⇒ xxx
  ├─ PatientBirthDate ⇒ 12345678
  └─ InstanceCreationDate ⇒ 12345678
```

- `with_keys = true` will replace the name with the associated tag (e.g. : (0x0010, 0x0020) if true and PatientID if false). Default is false.

- `maxdepth` defines the depth at which the DICOM tree is explored. Default is 2. Note that a high scan depth may take a few seconds to be displayed. 

Then, we can focus on a specific tag :

```Julia
Tree(dcm_file.ROIContourSequence, maxdepth = 3)
```

Output (with colours in the REPL) : 

```
└─ 1 ⇒
           ├─ ContourSequence ⇒
           │                      ├─ 1 ⇒
           │                      │        ├─ ContourGeometricType ⇒ CLOSED_PLANAR
           │                      │        ├─ ContourData ⇒ Vector
           │                      │        │                  ├─ Length ⇒ 3948
           │                      │        │                  ├─ ElementsType ⇒ Float64
           │                      │        │                  └─ Overview ⇒ [5.12, -245.33, -124.0, ..., -124.0, 4.4, -245.2]
           │                      │        │
           │                      │        ├─ ContourNumber ⇒ 0
           │                      │        ├─ NumberOfContourPoints ⇒ 1316
           │                      │        └─ ContourImageSequence ⇒ Vector of DICOMData
           │                      │                                    └─ Length ⇒ 1
           │                      │
           │                      │
           │                      ├─ 2 ⇒
           │                      │        ├─ ContourGeometricType ⇒ CLOSED_PLANAR
           │                      │        ├─ ContourData ⇒ Vector
           │                      │        │                  ├─ Length ⇒ 3936
           │                      │        │                  ├─ ElementsType ⇒ Float64
           │                      │        │                  └─ Overview ⇒ [12.78, -245.33, -122.0, ..., -122.0, 12.06, -245.2]
           │                      │        │
           │                      │        ├─ ContourNumber ⇒ 1
           │                      │        ├─ NumberOfContourPoints ⇒ 1312
           │                      │        └─ ContourImageSequence ⇒ Vector of DICOMData
           │                      │                                    └─ Length ⇒ 1
           ...
```