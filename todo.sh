#!/bin/bash

TASK_FILE="tasks.txt"

# Function to display the main menu
function show_menu {
    echo "To-Do List"
    echo "1. Add a new task"
    echo "2. View tasks"
    echo "3. Mark a task as complete"
    echo "4. Delete a task"
    echo "5. Exit"
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
    printf "%s\n" "${tasks[@]}" > "$TASK_FILE"  # Save tasks to the file
}

# Function to add a new task
function add_task {
    echo -n "Enter the task: "
    read task
    tasks+=("[ ] $task")  # Add the new task to the array
    save_tasks
    echo "Task added!"
}

# Function to view tasks with line numbers
function view_tasks {
    if [[ ${#tasks[@]} -gt 0 ]]; then
        echo "Your tasks:"
        for i in "${!tasks[@]}"; do
            printf "%d. %s\n" "$((i + 1))" "${tasks[$i]}"  # Display tasks with line numbers
        done
    else
        echo "No tasks found."
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
        echo "Task marked as complete!"
    else
        echo "Invalid task number."
    fi
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
        echo "Task deleted!"
    else
        echo "Invalid task number."
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
        *) echo "Invalid option. Please try again." ;;
    esac
    echo ""
done
