PERLMODULES = 

GPERLMODULES = $(PERLMODULES:.pm.in=.pm)

# +--------------------------------------------+
# | Workflow/S3                                |
# +--------------------------------------------+
WORKFLOWS3MODULES = \
    Workflow/S3/Uploader.pm.in

GWORKFLOWS3MODULES = $(WORKFLOWS3MODULES:.pm.in=.pm)

perl5lib_workflows3dir = $(perl5libdir)/Workflow/S3
perl5lib_workflows3_DATA = $(GWORKFLOWS3MODULES)

# +--------------------------------------------+
# | build rule for Workflow/S3/Uploader.pm.in  |
# +--------------------------------------------+
Workflow/S3/Uploader.pm: % : %.in 
	$(BUILD_PERL_MODULE_RULE)


# +--------------------------------------------+
# | Workflow                                   |
# +--------------------------------------------+
WORKFLOWMODULES = 
    
GWORKFLOWMODULES = $(WORKFLOWMODULES:.pm.in=.pm)

perl5lib_workflowdir = $(perl5libdir)/Workflow
perl5lib_workflow_DATA = $(GWORKFLOWMODULES)

ALLMODULES = \
    $(PERLMODULES) \
    $(WORKFLOWS3MODULES) \
    $(WORKFLOWMODULES)
