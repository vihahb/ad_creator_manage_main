#!/bin/bash

# =====================================================
# Flutter/iOS Code Randomizer & Obfuscator
# Purpose: Generate unique binary signatures for each build
# =====================================================
# 1. Generate code mới
# ./code_randomizer.sh generate 5 5
# => Tạo 5 class Swift và 5 class Dart
# =====================================================
# 2. Build với code ngẫu nhiên
# ./code_randomizer.sh build 10 10
# Tạo 10 class mỗi loại và build app
# =====================================================
# 3. Clean code đã generate:
# ./code_randomizer.sh clean
# =====================================================

set -e

# Configuration
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="${SCRIPT_DIR}"
IOS_DIR="${PROJECT_ROOT}/ios"
LIB_DIR="${PROJECT_ROOT}/lib"
OPENAI_API_KEY=""
USE_OPENAI=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =====================================================
# Utility Functions
# =====================================================

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

generate_random_string() {
    local length=${1:-10}
    cat /dev/urandom | LC_ALL=C tr -dc 'a-zA-Z0-9' | fold -w $length | head -n 1
}

generate_random_number() {
    local min=${1:-1000}
    local max=${2:-9999}
    echo $((min + RANDOM % (max - min + 1)))
}

# =====================================================
# Swift Code Generation
# =====================================================

generate_swift_dummy_code() {
    local class_count=${1:-5}
    local output_file="${IOS_DIR}/Runner/DummyCode.swift"

    log_info "Generating Swift dummy code..."

    cat > "$output_file" << 'EOF'
//
// Auto-generated file - DO NOT EDIT
// This file contains dummy code for binary obfuscation
//

import Foundation
import UIKit

EOF

    # Generate random classes
    for i in $(seq 1 $class_count); do
        local class_name="Generated$(generate_random_string 8)"
        local method_count=$((3 + RANDOM % 5))

        cat >> "$output_file" << EOF

@objc class ${class_name}: NSObject {
    private var id = "$(generate_random_string 32)"
    private var timestamp = Date().timeIntervalSince1970
    private var counter = $(generate_random_number 1000 99999)

EOF

        # Generate random methods
        for j in $(seq 1 $method_count); do
            local method_name="process$(generate_random_string 6)"
            local param_type=$((RANDOM % 3))

            case $param_type in
                0)
                    cat >> "$output_file" << EOF
    @objc func ${method_name}() -> String {
        let result = UUID().uuidString
        let processed = result.replacingOccurrences(of: "-", with: "")
        return String(processed.prefix($(generate_random_number 8 16)))
    }

EOF
                    ;;
                1)
                    cat >> "$output_file" << EOF
    @objc func ${method_name}(_ input: Int) -> Int {
        var result = input
        for _ in 0..<$(generate_random_number 5 15) {
            result = (result * $(generate_random_number 2 9)) % $(generate_random_number 1000 9999)
        }
        return result
    }

EOF
                    ;;
                2)
                    cat >> "$output_file" << EOF
    @objc func ${method_name}(_ text: String, count: Int) -> [String] {
        var results: [String] = []
        for i in 0..<count {
            let modified = text + "_\\(i)_$(generate_random_string 4)"
            results.append(modified)
        }
        return results.shuffled()
    }

EOF
                    ;;
            esac
        done

        echo "}" >> "$output_file"
    done

    # Add utility functions that will be called but optimized away
    # Using printf to avoid escape issues
    printf '%s\n' "" >> "$output_file"
    printf '%s\n' "// Utility class with complex but unused logic" >> "$output_file"
    printf '%s\n' "class ObfuscationHelper {" >> "$output_file"
    printf '%s\n' "    static let shared = ObfuscationHelper()" >> "$output_file"
    printf '%s\n' "    private var cache: [String: Any] = [:]" >> "$output_file"
    printf '%s\n' "    " >> "$output_file"
    printf '%s\n' "    private init() {" >> "$output_file"
    printf '%s\n' "        setupCache()" >> "$output_file"
    printf '%s\n' "    }" >> "$output_file"
    printf '%s\n' "    " >> "$output_file"
    printf '%s\n' "    private func setupCache() {" >> "$output_file"
    printf '%s\n' "        for i in 0..<$(generate_random_number 10 30) {" >> "$output_file"
    printf '%s\n' "            cache[\"key_\\(i)\"] = generateComplexValue(seed: i)" >> "$output_file"
    printf '%s\n' "        }" >> "$output_file"
    printf '%s\n' "    }" >> "$output_file"
    printf '%s\n' "    " >> "$output_file"
    printf '%s\n' "    private func generateComplexValue(seed: Int) -> Any {" >> "$output_file"
    printf '%s\n' "        switch seed % 4 {" >> "$output_file"
    printf '%s\n' "        case 0:" >> "$output_file"
    printf '%s\n' "            return Array(repeating: UUID().uuidString, count: seed)" >> "$output_file"
    printf '%s\n' "        case 1:" >> "$output_file"
    printf '%s\n' "            return Dictionary(uniqueKeysWithValues: (0..<seed).map { (\"k\\(\$0)\", \$0 * \$0) })" >> "$output_file"
    printf '%s\n' "        case 2:" >> "$output_file"
    printf '%s\n' "            return String(repeating: \"x\", count: seed * 100)" >> "$output_file"
    printf '%s\n' "        default:" >> "$output_file"
    printf '%s\n' "            return seed * seed * seed" >> "$output_file"
    printf '%s\n' "        }" >> "$output_file"
    printf '%s\n' "    }" >> "$output_file"
    printf '%s\n' "    " >> "$output_file"
    printf '%s\n' "    func process(_ input: String) -> String {" >> "$output_file"
    printf '%s\n' "        var result = input" >> "$output_file"
    printf '%s\n' "        for _ in 0..<$(generate_random_number 3 8) {" >> "$output_file"
    printf '%s\n' "            result = String(result.reversed())" >> "$output_file"
    printf '%s\n' "        }" >> "$output_file"
    printf '%s\n' "        return result" >> "$output_file"
    printf '%s\n' "    }" >> "$output_file"
    printf '%s\n' "}" >> "$output_file"
    printf '%s\n' "" >> "$output_file"
    printf '%s\n' "// Extension to add dummy functionality" >> "$output_file"
    printf '%s\n' "extension UIViewController {" >> "$output_file"
    printf '%s\n' "    @objc dynamic func dummyMethod_$(generate_random_string 8)() {" >> "$output_file"
    printf '%s\n' "        let _ = ObfuscationHelper.shared.process(\"$(generate_random_string 20)\")" >> "$output_file"
    printf '%s\n' "    }" >> "$output_file"
    printf '%s\n' "}" >> "$output_file"

    log_info "Swift dummy code generated: $output_file"
}

# =====================================================
# Dart Code Generation
# =====================================================

generate_dart_dummy_code() {
    local class_count=${1:-5}
    local output_file="${LIB_DIR}/generated/dummy_code.dart"

    mkdir -p "${LIB_DIR}/generated"
    log_info "Generating Dart dummy code..."

    cat > "$output_file" << 'EOF'
// Auto-generated file - DO NOT EDIT
// This file contains dummy code for binary obfuscation

import 'dart:math';
import 'dart:convert';
import 'dart:collection';

EOF

    # Generate random classes
    for i in $(seq 1 $class_count); do
        local class_name="Generated$(generate_random_string 8)"
        local method_count=$((3 + RANDOM % 5))

        cat >> "$output_file" << EOF

class ${class_name} {
  final String _id = '$(generate_random_string 32)';
  final int _seed = $(generate_random_number 1000 99999);
  late final Map<String, dynamic> _cache;

  ${class_name}() {
    _cache = _initializeCache();
  }

  Map<String, dynamic> _initializeCache() {
    final map = <String, dynamic>{};
    for (int i = 0; i < $(generate_random_number 10 30); i++) {
      map['key_\$i'] = _generateValue(i);
    }
    return map;
  }

  dynamic _generateValue(int seed) {
    switch (seed % 4) {
      case 0:
        return List.generate(seed, (i) => 'item_\${i}_$(generate_random_string 4)');
      case 1:
        return Map.fromIterables(
          List.generate(seed, (i) => 'k\$i'),
          List.generate(seed, (i) => i * i),
        );
      case 2:
        return base64.encode(utf8.encode('data_' * seed));
      default:
        return seed * seed * _seed;
    }
  }

EOF

        # Generate random methods with unique names
        for j in $(seq 1 $method_count); do
            local method_name="process$(generate_random_string 6)"
            local method_type=$((RANDOM % 4))

            case $method_type in
                0)
                    cat >> "$output_file" << EOF
  String ${method_name}() {
    final random = Random(_seed);
    final length = $(generate_random_number 10 20);
    final buffer = StringBuffer();
    for (int i = 0; i < length; i++) {
      buffer.write(random.nextInt($(generate_random_number 100 999)));
    }
    return buffer.toString();
  }

EOF
                    ;;
                1)
                    cat >> "$output_file" << EOF
  List<int> ${method_name}(int input) {
    final result = <int>[];
    var value = input;
    for (int i = 0; i < $(generate_random_number 5 15); i++) {
      value = (value * $(generate_random_number 2 9)) % $(generate_random_number 1000 9999);
      result.add(value);
    }
    return result..shuffle();
  }

EOF
                    ;;
                2)
                    # Generate unique transform method name for each class
                    local transform_method="_transform$(generate_random_string 4)"
                    cat >> "$output_file" << EOF
  Map<String, dynamic> ${method_name}(String key, dynamic value) {
    final map = HashMap<String, dynamic>();
    for (int i = 0; i < $(generate_random_number 3 10); i++) {
      final newKey = '\${key}_\${i}_$(generate_random_string 4)';
      map[newKey] = ${transform_method}(value, i);
    }
    return map;
  }

  dynamic ${transform_method}(dynamic value, int iteration) {
    if (value is String) {
      return '\${value.split('').reversed.join()}_\$iteration';
    } else if (value is int) {
      return value * iteration + _seed;
    } else if (value is List) {
      return value.map((e) => '\${e}_modified').toList();
    }
    return value;
  }

EOF
                    ;;
                3)
                    cat >> "$output_file" << EOF
  Future<String> ${method_name}Async() async {
    await Future.delayed(Duration(microseconds: $(generate_random_number 1 100)));
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final hash = (timestamp * _seed).toString();
    return 'async_\${hash.substring(0, min(8, hash.length))}';
  }

EOF
                    ;;
            esac
        done

        echo "}" >> "$output_file"
    done

    # Add singleton obfuscation manager
    cat >> "$output_file" << EOF

// Singleton obfuscation manager
class ObfuscationManager {
  static final ObfuscationManager _instance = ObfuscationManager._internal();
  factory ObfuscationManager() => _instance;

  final Random _random = Random($(generate_random_number 1000 99999));
  final Map<String, dynamic> _registry = {};

  ObfuscationManager._internal() {
    _initialize();
  }

  void _initialize() {
    for (int i = 0; i < $(generate_random_number 20 50); i++) {
      _registry['entry_\$i'] = _createEntry(i);
    }
  }

  dynamic _createEntry(int index) {
    switch (index % 5) {
      case 0:
        return DateTime.now().toIso8601String();
      case 1:
        return List.generate(index, (i) => _random.nextDouble());
      case 2:
        return {
          'index': index,
          'value': index * index,
          'id': '$(generate_random_string 16)',
        };
      case 3:
        return base64.encode(List.generate(index * 10, (i) => i));
      default:
        return 'entry_\${index}_$(generate_random_string 8)';
    }
  }

  void execute() {
    // This method is called but does nothing significant
    final temp = _registry.values.map((e) => e.hashCode).reduce((a, b) => a ^ b);
    final _ = temp.toString();
  }
}

// Mixin for adding dummy functionality
mixin DummyMixin {
  final String _mixinId = '$(generate_random_string 24)';

  void dummyOperation() {
    final list = List.generate($(generate_random_number 10 30), (i) => i * i);
    list.shuffle();
    final _ = list.fold<int>(0, (prev, element) => prev + element);
  }
}
EOF

    log_info "Dart dummy code generated: $output_file"
}

# =====================================================
# Using OpenAI API for Advanced Code Generation
# =====================================================

generate_code_with_openai() {
    local language=$1
    local purpose=$2

    if [ "$USE_OPENAI" != "true" ]; then
        log_info "Skipping OpenAI code generation (not enabled)"
        return
    fi

    if [ -z "$OPENAI_API_KEY" ] || [ "$OPENAI_API_KEY" == "your_api_key_here" ]; then
        log_warn "OpenAI API key not set. Skipping AI-generated code."
        return
    fi

    log_info "Generating $language code with OpenAI..."

    local prompt="Generate a $language class with 3-5 methods that perform complex but ultimately unused calculations. The code should:
1. Be syntactically correct
2. Include various data structures (arrays, maps, strings)
3. Have methods that call each other
4. Use random seeds: $(generate_random_number 1000 9999)
5. Include class names with suffix: $(generate_random_string 6)
6. Be designed for obfuscation purposes
7. Should compile but not affect app functionality
8. Add comments indicating auto-generation

Return only the code without explanations."

    local response=$(curl -s -X POST https://api.openai.com/v1/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -d '{
            "model": "gpt-3.5-turbo",
            "messages": [{"role": "user", "content": "'"$prompt"'"}],
            "temperature": 0.8,
            "max_tokens": 1000
        }')

    # Check if response contains error
    if echo "$response" | grep -q '"error"'; then
        log_error "OpenAI API error: $(echo "$response" | python3 -c "import sys, json; print(json.load(sys.stdin).get('error', {}).get('message', 'Unknown error'))" 2>/dev/null || echo "Failed to parse error")"
        return
    fi

    # Extract content from response
    local content=$(echo "$response" | python3 -c "import sys, json; print(json.load(sys.stdin)['choices'][0]['message']['content'])" 2>/dev/null)

    if [ -z "$content" ]; then
        log_error "Failed to extract content from OpenAI response"
        return
    fi

    if [ "$language" == "Swift" ]; then
        echo "$content" >> "${IOS_DIR}/Runner/AIGeneratedCode.swift"
        log_info "AI-generated Swift code added to AIGeneratedCode.swift"
    else
        mkdir -p "${LIB_DIR}/generated"
        echo "$content" >> "${LIB_DIR}/generated/ai_generated_code.dart"
        log_info "AI-generated Dart code added to ai_generated_code.dart"
    fi
}

# =====================================================
# Modify Existing Files
# =====================================================

inject_swift_calls() {
    local app_delegate="${IOS_DIR}/Runner/AppDelegate.swift"

    if ! grep -q "DummyCode initialization" "$app_delegate"; then
        log_info "Injecting Swift dummy code calls..."

        # Create a backup
        cp "$app_delegate" "${app_delegate}.backup"

        # Inject initialization code
        sed -i '' '/override func application/a\
        // DummyCode initialization - Auto-generated\
        DispatchQueue.global(qos: .background).async {\
            let _ = ObfuscationHelper.shared\
            for i in 0..<3 {\
                let className = "Generated" + String(format: "%08x", arc4random())\
                if let cls = NSClassFromString("Runner." + className) as? NSObject.Type {\
                    let _ = cls.init()\
                }\
            }\
        }
' "$app_delegate"
    fi
}

inject_dart_imports() {
    local main_file="${LIB_DIR}/main.dart"

    log_info "Injecting Dart imports and initialization..."

    # Create a backup if it doesn't exist
    if [ ! -f "${main_file}.backup" ]; then
        cp "$main_file" "${main_file}.backup"
    fi

    # Check if import already exists
    if ! grep -q "generated/dummy_code.dart" "$main_file"; then
        log_info "Adding import to main.dart..."

        # Add import after existing imports or at the beginning
        if grep -q "^import " "$main_file"; then
            # Find the last import line and add after it
            # Use a more robust approach with sed
            last_import=$(grep -n "^import " "$main_file" | tail -1 | cut -d: -f1)
            if [ ! -z "$last_import" ]; then
                sed -i '' "${last_import}a\\
import 'generated/dummy_code.dart';
" "$main_file"
            fi
        else
            # Add at the beginning if no imports exist
            sed -i '' "1i\\
import 'generated/dummy_code.dart';\\
" "$main_file"
        fi
    fi

    # Check if initialization already exists
    if ! grep -q "ObfuscationManager().execute()" "$main_file"; then
        log_info "Adding initialization code to main()..."

        # Try different main function patterns
        local main_found=false

        # Pattern 1: void main() with or without async
        if grep -E "^[[:space:]]*void[[:space:]]+main[[:space:]]*\(" "$main_file" > /dev/null; then
            main_found=true
            log_info "Found void main() pattern"

            # Use Python for more reliable text processing
            python3 << 'PYTHON_SCRIPT' "$main_file"
import sys
import re

file_path = sys.argv[1]

with open(file_path, 'r') as f:
    content = f.read()

# Find main function and inject code
# Pattern matches various main() declarations
patterns = [
    r'(void\s+main\s*\([^)]*\)\s*async\s*{)',  # async main
    r'(void\s+main\s*\([^)]*\)\s*{)',           # sync main
    r'(Future<void>\s+main\s*\([^)]*\)\s*async\s*{)',  # Future main
    r'(Future<void>\s+main\s*\([^)]*\)\s*{)',   # Future main without async
    r'(main\s*\([^)]*\)\s*async\s*{)',          # main without return type
    r'(main\s*\([^)]*\)\s*{)',                  # simple main
]

injection_code = """
  // Initialize obfuscation - Auto-generated
  try {
    ObfuscationManager().execute();
    // Initialize dummy classes
    for (int i = 0; i < 3; i++) {
      final dummy = ObfuscationManager();
      dummy.execute();
    }
  } catch (e) {
    // Silently ignore obfuscation errors
  }
"""

modified = False
for pattern in patterns:
    if re.search(pattern, content, re.MULTILINE):
        # Find the main function and inject after the opening brace
        content = re.sub(
            pattern,
            r'\1' + injection_code,
            content,
            count=1
        )
        modified = True
        print(f"Injected code using pattern: {pattern}")
        break

if modified:
    with open(file_path, 'w') as f:
        f.write(content)
    print("Successfully injected obfuscation code")
else:
    print("Could not find main() function pattern")

PYTHON_SCRIPT

        # Pattern 2: Try to find runApp if main() is not standard
        elif grep -q "runApp" "$main_file"; then
            main_found=true
            log_info "Found runApp() - injecting before it"

            # Inject before runApp
            sed -i '' '/runApp/i\
  // Initialize obfuscation - Auto-generated\
  try {\
    ObfuscationManager().execute();\
    // Initialize dummy classes\
    for (int i = 0; i < 3; i++) {\
      final dummy = ObfuscationManager();\
      dummy.execute();\
    }\
  } catch (e) {\
    // Silently ignore obfuscation errors\
  }\
' "$main_file"
        fi

        if [ "$main_found" = false ]; then
            log_warn "Could not find main() function or runApp() in $main_file"
            log_warn "Please manually add the following code to your main() function:"
            echo "  ObfuscationManager().execute();"

            # Create a helper file with instructions
            cat > "${LIB_DIR}/obfuscation_init.dart" << 'EOF'
// Add this import to your main.dart:
import 'generated/dummy_code.dart';

// Add this code inside your main() function:
void initObfuscation() {
  try {
    ObfuscationManager().execute();
    // Initialize dummy classes
    for (int i = 0; i < 3; i++) {
      final dummy = ObfuscationManager();
      dummy.execute();
    }
  } catch (e) {
    // Silently ignore obfuscation errors
  }
}

// Then call initObfuscation() in your main():
// void main() {
//   initObfuscation();
//   runApp(MyApp());
// }
EOF
            log_info "Created helper file: ${LIB_DIR}/obfuscation_init.dart"
        fi
    else
        log_info "Obfuscation already initialized in main.dart"
    fi

    log_info "Dart injection completed"
}

# =====================================================
# Build Modification
# =====================================================

modify_build_settings() {
    log_info "Modifying build settings for additional obfuscation..."

    # Add random build flags
    local xcconfig="${IOS_DIR}/Flutter/Release.xcconfig"
    if [ -f "$xcconfig" ]; then
        echo "" >> "$xcconfig"
        echo "// Auto-generated build flags" >> "$xcconfig"
        echo "OTHER_SWIFT_FLAGS = \$(inherited) -D RANDOM_$(generate_random_string 8)" >> "$xcconfig"
        echo "GCC_PREPROCESSOR_DEFINITIONS = \$(inherited) OBFUSCATE_$(generate_random_number 10000 99999)=1" >> "$xcconfig"
    fi

    # Modify Dart compile flags
    local pubspec="${PROJECT_ROOT}/pubspec.yaml"
    if [ -f "$pubspec" ]; then
        # Add obfuscation to build command
        echo "" >> "$pubspec"
        echo "# Auto-generated build configuration" >> "$pubspec"
        echo "# Use: flutter build ios --obfuscate --split-debug-info=build/debug" >> "$pubspec"
    fi
}

# =====================================================
# Clean Up Functions
# =====================================================

clean_generated_files() {
    log_info "Cleaning previously generated files..."

    rm -f "${IOS_DIR}/Runner/DummyCode.swift"
    rm -f "${IOS_DIR}/Runner/AIGeneratedCode.swift"
    rm -rf "${LIB_DIR}/generated"

    # Restore backups if they exist
    if [ -f "${IOS_DIR}/Runner/AppDelegate.swift.backup" ]; then
        mv "${IOS_DIR}/Runner/AppDelegate.swift.backup" "${IOS_DIR}/Runner/AppDelegate.swift"
    fi

    if [ -f "${LIB_DIR}/main.dart.backup" ]; then
        mv "${LIB_DIR}/main.dart.backup" "${LIB_DIR}/main.dart"
    fi
}

# =====================================================
# OpenAI Configuration
# =====================================================

configure_openai() {
    echo ""
    echo -e "${BLUE}======================================"
    echo "OpenAI Configuration"
    echo "======================================${NC}"
    echo ""
    echo "Choose code generation method:"
    echo "1) Local generation only (no API needed)"
    echo "2) Local + OpenAI generation (requires API key)"
    echo ""
    read -p "Enter choice [1-2]: " openai_choice

    case $openai_choice in
        1)
            USE_OPENAI=false
            log_info "Using local code generation only"
            ;;
        2)
            USE_OPENAI=true
            echo ""
            echo -e "${YELLOW}OpenAI API Key Required${NC}"
            echo "Get your API key from: https://platform.openai.com/api-keys"
            echo ""

            # Check if API key exists in environment
            if [ ! -z "$OPENAI_API_KEY" ] && [ "$OPENAI_API_KEY" != "your_api_key_here" ]; then
                echo -e "${GREEN}Found existing API key in environment${NC}"
                read -p "Use existing API key? (y/n): " use_existing
                if [ "$use_existing" != "y" ]; then
                    read -s -p "Enter your OpenAI API key: " api_key
                    echo ""
                    OPENAI_API_KEY="$api_key"
                fi
            else
                read -s -p "Enter your OpenAI API key: " api_key
                echo ""
                OPENAI_API_KEY="$api_key"
            fi

            # Validate API key format
            if [[ ! "$OPENAI_API_KEY" =~ ^sk-[a-zA-Z0-9]{48}$ ]]; then
                log_warn "API key format seems incorrect. Expected format: sk-..."
                read -p "Continue anyway? (y/n): " continue_anyway
                if [ "$continue_anyway" != "y" ]; then
                    USE_OPENAI=false
                    log_info "Falling back to local generation only"
                fi
            else
                log_info "OpenAI API key configured successfully"
            fi

            # Test API key
            if [ "$USE_OPENAI" == "true" ]; then
                echo -e "${YELLOW}Testing OpenAI API connection...${NC}"
                test_response=$(curl -s -o /dev/null -w "%{http_code}" \
                    -H "Authorization: Bearer $OPENAI_API_KEY" \
                    https://api.openai.com/v1/models)

                if [ "$test_response" == "200" ]; then
                    echo -e "${GREEN}✓ API key is valid${NC}"
                elif [ "$test_response" == "401" ]; then
                    echo -e "${RED}✗ Invalid API key${NC}"
                    USE_OPENAI=false
                    log_info "Falling back to local generation only"
                else
                    echo -e "${YELLOW}⚠ Could not verify API key (HTTP $test_response)${NC}"
                fi
            fi
            ;;
        *)
            log_warn "Invalid choice. Using local generation only"
            USE_OPENAI=false
            ;;
    esac

    echo ""
}

# =====================================================
# Main Execution
# =====================================================

main() {
    echo "======================================"
    echo "Code Randomizer & Obfuscator"
    echo "======================================"

    # Parse arguments
    local action="${1:-generate}"
    local swift_classes="${2:-5}"
    local dart_classes="${3:-5}"

    case "$action" in
        generate)
            log_info "Starting code generation..."

            # Configure OpenAI
            configure_openai

            # Generate dummy code
            generate_swift_dummy_code "$swift_classes"
            generate_dart_dummy_code "$dart_classes"

            # Generate AI code if configured
            if [ "$USE_OPENAI" == "true" ]; then
                generate_code_with_openai "Swift" "obfuscation"
                generate_code_with_openai "Dart" "obfuscation"
            fi

            # Inject calls
            inject_swift_calls
            inject_dart_imports

            # Modify build settings
            modify_build_settings

            log_info "Code generation completed!"

            # Summary
            echo ""
            echo -e "${BLUE}======================================"
            echo "Generation Summary"
            echo "======================================${NC}"
            echo "• Swift classes generated: $swift_classes"
            echo "• Dart classes generated: $dart_classes"
            echo "• OpenAI enhancement: $([ "$USE_OPENAI" == "true" ] && echo "Yes" || echo "No")"
            echo ""
            echo -e "${GREEN}Next steps:${NC}"
            echo "1. Verify: ./dart_verifier.sh"
            echo "2. Build: flutter build ios --obfuscate --split-debug-info=build/debug"
            ;;

        clean)
            log_info "Cleaning generated files..."
            clean_generated_files
            log_info "Cleanup completed!"
            ;;

        build)
            log_info "Generating code and building..."

            # Configure OpenAI
            configure_openai

            # Clean first
            clean_generated_files

            # Generate new code
            generate_swift_dummy_code "$swift_classes"
            generate_dart_dummy_code "$dart_classes"

            # Generate AI code if configured
            if [ "$USE_OPENAI" == "true" ]; then
                generate_code_with_openai "Swift" "obfuscation"
                generate_code_with_openai "Dart" "obfuscation"
            fi

            inject_swift_calls
            inject_dart_imports
            modify_build_settings

            # Build
            cd "$PROJECT_ROOT"
            flutter clean
            flutter pub get
            cd ios && pod install && cd ..
            flutter build ios --obfuscate --split-debug-info=build/debug --release

            log_info "Build completed!"
            ;;

        config)
            # Just configure OpenAI without generating
            configure_openai

            # Save config for future use
            if [ "$USE_OPENAI" == "true" ] && [ ! -z "$OPENAI_API_KEY" ]; then
                echo ""
                read -p "Save API key for future use? (y/n): " save_key
                if [ "$save_key" == "y" ]; then
                    echo "export OPENAI_API_KEY='$OPENAI_API_KEY'" > "${SCRIPT_DIR}/.env"
                    echo -e "${GREEN}API key saved to .env file${NC}"
                    echo "Add to .gitignore: echo '.env' >> .gitignore"
                fi
            fi
            ;;

        *)
            echo "Usage: $0 [generate|clean|build|config] [swift_classes] [dart_classes]"
            echo ""
            echo "Actions:"
            echo "  generate - Generate random code (default)"
            echo "  clean    - Remove all generated code"
            echo "  build    - Generate code and build the app"
            echo "  config   - Configure OpenAI settings only"
            echo ""
            echo "Examples:"
            echo "  $0 generate 5 5  # Generate 5 Swift and 5 Dart classes"
            echo "  $0 build 10 10   # Generate 10 classes each and build"
            echo "  $0 clean         # Clean all generated files"
            echo "  $0 config        # Configure OpenAI API key"
            echo ""
            echo "Environment Variables:"
            echo "  OPENAI_API_KEY - Set this to skip API key prompt"
            exit 1
            ;;
    esac
}

# Load .env file if exists
if [ -f "${SCRIPT_DIR}/.env" ]; then
    source "${SCRIPT_DIR}/.env"
fi

# Run main function
main "$@"