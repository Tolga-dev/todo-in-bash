#!/bin/bash

TASK_FILE="tasks.txt"

# Color codes
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

# Function to display colored messages
function display_echo {
    local color="$1"
    shift
    echo -e "${color}$@${RESET}"  # Print the message with the specified color
}

# Function to display the main menu
function show_menu {
    display_echo "$BLUE" "To-Do List"
    display_echo "$YELLOW" "1. Add a new task"
    display_echo "$YELLOW" "2. View tasks"
    display_echo "$YELLOW" "3. Mark a task as complete"
    display_echo "$YELLOW" "4. Delete a task"
    display_echo "$YELLOW" "5. Exit"
    echo -n "Choose an option: "
}

# Function to load tasks from the file into an array
function load_tasks {
    if [[ -f "$TASK_FILE" ]]; then
        mapfile -t tasks < "$TASK_FILE"  # Load tasks into an array
    else
        tasks=()  # Initialize an empty array if the file doesn't exist
    fi
}

# Function to save tasks from the array back to the file
function save_tasks { 
    printf "%s\n" "${tasks[@]}" "  " > "$TASK_FILE"  # Save tasks to the file
}

# Function to add a new task
function add_task {
    now_hourly=$(date +%d-%b-%H_%M)    
    echo -n "Enter the task: "
    read task
    tasks+=("[ ] $task saved on $now_hourly")  # Add the new task to the array
    save_tasks
    display_echo "$GREEN" "Task added!"
    view_tasks
}

# Function to view tasks with line numbers
function view_tasks {
    if [[ ${#tasks[@]} -gt 0 ]]; then
        display_echo "$BLUE" "Your tasks:"
        for i in "${!tasks[@]}"; do
            if [[ "${tasks[$i]}" == "[x]"* ]]; then
                # Task is complete
                printf "%d. ${GREEN}%s${RESET}\n" "$((i + 1))" "${tasks[$i]}"
            else
                # Task is incomplete
                printf "%d. ${RED}%s${RESET}\n" "$((i + 1))" "${tasks[$i]}"
            fi
        done
    else
        display_echo "$RED" "No tasks found."
    fi
}


# Function to mark a task as complete
function mark_complete {
    view_tasks
    echo -n "Enter the task number to mark as complete: "
    read task_number
    if [[ $task_number -ge 1 && $task_number -le ${#tasks[@]} ]]; then
        tasks[$((task_number - 1))]="[x] ${tasks[$((task_number - 1))]:4}"  # Mark the task as complete
        save_tasks
        display_echo "$GREEN" "Task marked as complete!"
    else
        display_echo "$RED" "Invalid task number."
    fi
    
    view_tasks
}

# Function to delete a task
function delete_task {
    view_tasks
    echo -n "Enter the task number to delete: "
    read task_number
    if [[ $task_number -ge 1 && $task_number -le ${#tasks[@]} ]]; then
        unset 'tasks[$((task_number - 1))]'  # Delete the specified task
        tasks=("${tasks[@]}")  # Re-index the array
        save_tasks
        display_echo "$GREEN" "Task deleted!"
    else
        display_echo "$RED" "Invalid task number."
    fi
}

# Main loop
load_tasks  # Load tasks at the start
while true; do
    show_menu
    read option
    case $option in
        1) add_task ;;
        2) view_tasks ;;
        3) mark_complete ;;
        4) delete_task ;;
        5) exit 0 ;;
        *) display_echo "$RED" "Invalid option. Please try again." ;;
    esac
    echo ""
done
