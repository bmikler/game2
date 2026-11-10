@echo off
rem Wrapper: measure.cmd [--aug 9] [--sim koncept.png] obraz1.png ...   (CSV na stdout)
"%~dp0venv\Scripts\python.exe" "%~dp0measure.py" %*
