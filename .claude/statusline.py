#!/usr/bin/env python3
import json
import sys
import os
import subprocess

def get_git_branch(project_dir):
    """Get the current git branch name."""
    try:
        if not project_dir or not os.path.isdir(project_dir):
            return None
        result = subprocess.run(['git', 'branch', '--show-current'], 
                              capture_output=True, text=True, cwd=project_dir)
        if result.returncode == 0:
            return result.stdout.strip()
    except:
        pass
    return None

def main():
    try:
        # Read JSON input from stdin
        input_data = json.loads(sys.stdin.read())
        
        # Extract information
        model_name = input_data.get('model', {}).get('display_name', 'Unknown')
        project_dir = input_data.get('workspace', {}).get('project_dir', '')
        project_name = os.path.basename(project_dir) if project_dir else 'No Project'
        output_style = input_data.get('output_style', {}).get('name', 'default')
        
        # Get git branch
        git_branch = get_git_branch(project_dir)
        
        # Build status line components
        components = []
        
        # Model with robot emoji
        components.append(f"\033[36m🤖 {model_name}\033[0m")
        
        # Project with folder emoji
        components.append(f"\033[33m📁 {project_name}\033[0m")
        
        # Git branch with git emoji (if available)
        if git_branch:
            components.append(f"\033[32m🔀 {git_branch}\033[0m")
        
        # Output style with gear emoji
        components.append(f"\033[35m⚙️ {output_style}\033[0m")
        
        # Join with pipe separator
        status_line = " \033[37m|\033[0m ".join(components)
        
        print(status_line)
        
    except Exception as e:
        # Fallback status line
        print(f"\033[31m❌ Status Error\033[0m")

if __name__ == "__main__":
    main()