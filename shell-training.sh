#!/bin/bash
# DB-GPT Shell Training Guide
# This script provides a structured training program for learning shell commands and scripting
# using the enhanced shell agent.

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Get project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default settings
DEFAULT_MODEL="codellama"
LESSONS_FILE="$PROJECT_ROOT/.shell_training_lessons"
PROGRESS_FILE="$PROJECT_ROOT/.shell_training_progress"
CHALLENGE_FILE="$PROJECT_ROOT/.shell_training_challenge"

# Parse command line arguments
model="$DEFAULT_MODEL"
lesson_number=0
reset_progress=false

print_help() {
    echo -e "${CYAN}DB-GPT Shell Training Guide${NC}"
    echo ""
    echo "Usage: $(basename "$0") [options]"
    echo ""
    echo "Options:"
    echo "  --model MODEL          - Model to use (default: codellama)"
    echo "  --lesson NUMBER        - Start at a specific lesson number"
    echo "  --reset                - Reset training progress"
    echo "  --list                 - List available lessons"
    echo "  --help                 - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $(basename "$0") --model llama3"
    echo "  $(basename "$0") --lesson 3"
    echo ""
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --model)
            model="$2"
            shift 2
            ;;
        --lesson)
            lesson_number="$2"
            shift 2
            ;;
        --reset)
            reset_progress=true
            shift
            ;;
        --list)
            list_lessons=true
            shift
            ;;
        --help)
            print_help
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            print_help
            exit 1
            ;;
    esac
done

# Initialize or reset training files
initialize_training_files() {
    if [ "$reset_progress" = true ] || [ ! -f "$LESSONS_FILE" ]; then
        # Create lessons file with predefined lessons
        cat > "$LESSONS_FILE" << EOL
1|Basic Navigation|Learn to navigate the file system using cd, ls, and pwd|File Navigation
2|File Operations|Learn to create, copy, move, and delete files and directories|File Management
3|Text Processing|Learn to view and manipulate text with cat, grep, sed, and awk|Text Processing
4|Pipes and Redirection|Learn to use pipes and redirection to combine commands|Command Chaining
5|Shell Scripting Basics|Learn to write simple shell scripts with variables and control flow|Scripting
6|Process Management|Learn to manage processes with ps, kill, bg, fg, and top|Process Control
7|User and Permissions|Learn about users, groups, and file permissions|User Management
8|Environment Variables|Learn to work with and modify environment variables|Environment Setup
9|Regular Expressions|Learn to use regular expressions in grep, sed, and awk|Pattern Matching
10|Advanced Scripting|Learn advanced shell scripting techniques|Advanced Topics
EOL
        
        # Initialize progress file
        echo "0" > "$PROGRESS_FILE"
        
        echo -e "${GREEN}Training data initialized!${NC}"
    fi
}

# Get current progress
get_current_progress() {
    if [ -f "$PROGRESS_FILE" ]; then
        cat "$PROGRESS_FILE"
    else
        echo "0"
    fi
}

# Set current progress
set_current_progress() {
    echo "$1" > "$PROGRESS_FILE"
}

# List all available lessons
list_all_lessons() {
    echo -e "${CYAN}Available Shell Training Lessons:${NC}"
    echo -e "${YELLOW}===========================================${NC}"
    
    while IFS='|' read -r number title description category; do
        echo -e "${GREEN}Lesson $number:${NC} $title - $category"
        echo "  $description"
        echo ""
    done < "$LESSONS_FILE"
}

# Get lesson details by number
get_lesson_details() {
    local lesson_num="$1"
    local lesson_data=$(grep "^$lesson_num|" "$LESSONS_FILE")
    
    if [ -z "$lesson_data" ]; then
        echo -e "${RED}Error: Lesson $lesson_num not found${NC}"
        exit 1
    fi
    
    echo "$lesson_data"
}

# Generate lesson challenge
generate_lesson_challenge() {
    local lesson_data="$1"
    local lesson_num=$(echo "$lesson_data" | cut -d'|' -f1)
    local lesson_title=$(echo "$lesson_data" | cut -d'|' -f2)
    local lesson_desc=$(echo "$lesson_data" | cut -d'|' -f3)
    local lesson_category=$(echo "$lesson_data" | cut -d'|' -f4)
    
    # Create challenge prompt for the shell agent
    local challenge_prompt="You are a shell training assistant. Create a series of 5 practical exercises for a student learning about '$lesson_title'. 

For each exercise:
1. Provide a clear, specific task
2. Include hints for how to approach it
3. Show the expected command or solution
4. Explain why this solution works

Focus area: $lesson_desc
Category: $lesson_category
Lesson number: $lesson_num

Format your response with clear headings and numbered exercises. Make the exercises progressively more challenging."

    # Save challenge to file
    echo "$challenge_prompt" > "$CHALLENGE_FILE"
    
    echo -e "${BLUE}Lesson $lesson_num:${NC} $lesson_title"
    echo -e "${BLUE}Description:${NC} $lesson_desc"
    echo -e "${BLUE}Category:${NC} $lesson_category"
}

# Start shell agent with lesson challenge
launch_lesson() {
    local lesson_num="$1"
    
    # Get the lesson details
    local lesson_data=$(get_lesson_details "$lesson_num")
    
    # Generate the challenge
    generate_lesson_challenge "$lesson_data"
    
    # Launch the shell agent with the challenge
    echo -e "${CYAN}Launching Shell Training Session for Lesson $lesson_num${NC}"
    echo -e "${CYAN}===========================================${NC}"
    echo ""
    echo -e "${YELLOW}The shell agent will now provide exercises for this lesson.${NC}"
    echo -e "${YELLOW}Follow the instructions and practice each exercise.${NC}"
    echo ""
    echo -e "Press ${GREEN}Enter${NC} to continue..."
    read
    
    # Read the challenge prompt
    local challenge=$(cat "$CHALLENGE_FILE")
    
    # Launch enhanced shell agent with the challenge as a task
    "$PROJECT_ROOT/tools/ollama/enhanced_shell_agent.sh" --model "$model" --mode shell --task "$challenge"
    
    # After completing the lesson
    echo ""
    echo -e "${CYAN}===========================================${NC}"
    echo -e "${GREEN}Lesson $lesson_num completed!${NC}"
    
    # Update progress if this is a new lesson
    local current_progress=$(get_current_progress)
    if [ "$lesson_num" -gt "$current_progress" ]; then
        set_current_progress "$lesson_num"
        echo -e "${GREEN}Progress updated. You've completed $lesson_num out of 10 lessons.${NC}"
    fi
    
    echo ""
    echo -e "Would you like to continue to the next lesson? (y/n)"
    read -p "> " continue_answer
    
    if [[ "$continue_answer" == "y" || "$continue_answer" == "Y" ]]; then
        next_lesson=$((lesson_num + 1))
        if [ "$next_lesson" -le 10 ]; then
            launch_lesson "$next_lesson"
        else
            echo -e "${GREEN}Congratulations! You've completed all available lessons.${NC}"
        fi
    fi
}

# Main execution
initialize_training_files

if [ "$list_lessons" = true ]; then
    list_all_lessons
    exit 0
fi

# If lesson number is not set, use the saved progress
if [ "$lesson_number" -eq 0 ]; then
    lesson_number=$(get_current_progress)
    # If progress is 0, start with lesson 1
    if [ "$lesson_number" -eq 0 ]; then
        lesson_number=1
    fi
fi

# Display welcome message
echo -e "${CYAN}=========================================${NC}"
echo -e "${CYAN}    DB-GPT Shell Training Guide         ${NC}"
echo -e "${CYAN}=========================================${NC}"
echo ""
echo -e "${BLUE}Welcome to your personalized shell training session!${NC}"
echo -e "${BLUE}This guide will help you learn and practice shell commands${NC}"
echo -e "${BLUE}with the assistance of our enhanced shell agent.${NC}"
echo ""
echo -e "${YELLOW}Current progress:${NC} Lesson $lesson_number of 10"
echo -e "${YELLOW}Selected model:${NC} $model"
echo ""

# Offer options
echo -e "What would you like to do?"
echo -e "  ${GREEN}1${NC} - Continue from Lesson $lesson_number"
echo -e "  ${GREEN}2${NC} - List all available lessons"
echo -e "  ${GREEN}3${NC} - Start from a different lesson"
echo -e "  ${GREEN}4${NC} - Reset progress"
echo -e "  ${GREEN}5${NC} - Exit"
echo ""
read -p "> " user_choice

case "$user_choice" in
    1)
        launch_lesson "$lesson_number"
        ;;
    2)
        list_all_lessons
        echo ""
        echo -e "Which lesson would you like to start? (Enter lesson number)"
        read -p "> " selected_lesson
        launch_lesson "$selected_lesson"
        ;;
    3)
        echo -e "Enter the lesson number (1-10):"
        read -p "> " selected_lesson
        if [[ "$selected_lesson" =~ ^[0-9]+$ ]] && [ "$selected_lesson" -ge 1 ] && [ "$selected_lesson" -le 10 ]; then
            launch_lesson "$selected_lesson"
        else
            echo -e "${RED}Invalid lesson number. Must be between 1 and 10.${NC}"
        fi
        ;;
    4)
        echo -e "${YELLOW}Warning: This will reset all your training progress.${NC}"
        echo -e "Are you sure? (y/n)"
        read -p "> " confirm_reset
        if [[ "$confirm_reset" == "y" || "$confirm_reset" == "Y" ]]; then
            reset_progress=true
            initialize_training_files
            echo -e "${GREEN}Progress reset. Starting from Lesson 1.${NC}"
            launch_lesson 1
        fi
        ;;
    5)
        echo -e "${GREEN}Exiting shell training guide. Goodbye!${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid choice.${NC}"
        ;;
esac
