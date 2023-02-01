#-----------------------------------------------------------------------------
set(MODULE_NAME SlicerCustomAppUtilities)

#-----------------------------------------------------------------------------
set(MODULE_PYTHON_SCRIPTS
  SlicerCustomAppUtilities/__init__.py
  )

set(MODULE_PYTHON_RESOURCES
  )

#-----------------------------------------------------------------------------
slicerMacroBuildScriptedModule(
  NAME ${MODULE_NAME}
  SCRIPTS ${MODULE_PYTHON_SCRIPTS}
  RESOURCES ${MODULE_PYTHON_RESOURCES}
  )
