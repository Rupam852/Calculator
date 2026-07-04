// Calculator State
let currentInput = '0';
let previousValue = null;
let activeOperator = null;
let shouldResetDisplay = false;
let expression = '';
let history = [];

// DOM Elements
const currentDisplayEl = document.getElementById('current-display');
const expressionDisplayEl = document.getElementById('expression-display');
const themeToggleBtn = document.getElementById('theme-toggle');
const historyToggleBtn = document.getElementById('history-toggle');
const historyDrawerEl = document.getElementById('history-drawer');
const closeHistoryBtn = document.getElementById('close-history');
const clearHistoryBtn = document.getElementById('clear-history');
const historyListEl = document.getElementById('history-list');

// Initialize App
document.addEventListener('DOMContentLoaded', () => {
    loadTheme();
    loadHistory();
    setupEventListeners();
});

// Theme Setup
function loadTheme() {
    const savedTheme = localStorage.getItem('calculator-theme') || 'dark';
    document.documentElement.setAttribute('data-theme', savedTheme);
}

function toggleTheme() {
    const currentTheme = document.documentElement.getAttribute('data-theme');
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
    document.documentElement.setAttribute('data-theme', newTheme);
    safeSetStorage('calculator-theme', newTheme);
}

// History Setup
function loadHistory() {
    const savedHistory = localStorage.getItem('calculator-history');
    if (savedHistory) {
        try {
            history = JSON.parse(savedHistory);
        } catch (e) {
            history = [];
        }
    }
    renderHistory();
}

function saveHistory() {
    safeSetStorage('calculator-history', JSON.stringify(history));
    renderHistory();
}

function addHistoryItem(expr, result) {
    // Prevent duplicate entries
    if (history.length > 0 && history[0].expression === expr && history[0].result === result) {
        return;
    }
    history.unshift({ expression: expr, result: result });
    // Cap history at 50 entries
    if (history.length > 50) {
        history.pop();
    }
    saveHistory();
}

function renderHistory() {
    if (!historyListEl) return;
    
    if (history.length === 0) {
        historyListEl.innerHTML = '<div class="empty-history-msg">No history yet</div>';
        return;
    }

    historyListEl.innerHTML = '';
    history.forEach((item, index) => {
        const div = document.createElement('div');
        div.className = 'history-item';
        div.dataset.index = index;
        div.innerHTML = `
            <div class="history-item-expr">${escapeHtml(item.expression)}</div>
            <div class="history-item-result">${escapeHtml(item.result)}</div>
        `;
        div.addEventListener('click', () => {
            currentInput = item.result;
            previousValue = null;
            activeOperator = null;
            expression = '';
            shouldResetDisplay = false;
            updateDisplay();
            closeHistory();
        });
        historyListEl.appendChild(div);
    });
}

function clearHistory() {
    history = [];
    saveHistory();
}

// Helpers
function escapeHtml(str) {
    return str.replace(/&/g, '&amp;')
              .replace(/</g, '&lt;')
              .replace(/>/g, '&gt;')
              .replace(/"/g, '&quot;')
              .replace(/'/g, '&#039;');
}

function safeSetStorage(key, value) {
    try {
        localStorage.setItem(key, value);
    } catch (e) {
        console.warn('LocalStorage access is blocked or full:', e);
    }
}

function openHistory() {
    historyDrawerEl.classList.add('active');
}

function closeHistory() {
    historyDrawerEl.classList.remove('active');
}

// Display Management
function updateDisplay() {
    // Handle display value formatting with scientific notation helper
    currentDisplayEl.textContent = formatScientificDisplay(currentInput);
    
    // Dynamic Font Sizing for current input
    const length = currentInput.length;
    if (length <= 8) {
        currentDisplayEl.style.fontSize = '2.2rem';
    } else if (length <= 12) {
        currentDisplayEl.style.fontSize = '1.65rem'; // 75%
    } else if (length <= 16) {
        currentDisplayEl.style.fontSize = '1.2rem'; // 55%
    } else {
        currentDisplayEl.style.fontSize = '0.92rem'; // 42%
    }
    
    // Formatting the expression preview
    let displayExpression = expression;
    if (activeOperator) {
        const opSymbols = { add: '+', subtract: '−', multiply: '×', divide: '÷' };
        displayExpression += ` ${opSymbols[activeOperator] || ''}`;
    }
    expressionDisplayEl.textContent = formatScientificDisplay(displayExpression);
    
    // Dynamic Font Sizing for expression preview
    const exprLength = displayExpression.length;
    if (exprLength <= 15) {
        expressionDisplayEl.style.fontSize = '0.95rem';
    } else if (exprLength <= 25) {
        expressionDisplayEl.style.fontSize = '0.74rem'; // 78%
    } else {
        expressionDisplayEl.style.fontSize = '0.6rem'; // 64%
    }
}

function formatScientificDisplay(val) {
    if (!val.includes('e')) return val;
    const expRegex = /([0-9.]+e[+-]?[0-9]+)/g;
    return val.replace(expRegex, (matchStr) => {
        const parts = matchStr.split('e');
        if (parts.length === 2) {
            const cleanExp = parts[1].replace('+', '');
            const superscripts = {
                '0': '⁰', '1': '¹', '2': '²', '3': '³', '4': '⁴',
                '5': '⁵', '6': '⁶', '7': '⁷', '8': '⁸', '9': '⁹',
                '-': '⁻'
            };
            let formattedExp = '';
            for (let i = 0; i < cleanExp.length; i++) {
                const char = cleanExp[i];
                formattedExp += superscripts[char] || char;
            }
            return `${parts[0]} × 10${formattedExp}`;
        }
        return matchStr;
    });
}

// Precision Rounding helper
function formatNumber(value) {
    const num = parseFloat(value);
    if (isNaN(num)) return 'Error';
    if (!isFinite(num)) return 'Error';
    
    const absVal = Math.abs(num);
    // Use scientific notation for extremely large or small values
    if (absVal >= 1e15 || (absVal > 0 && absVal < 1e-7)) {
        let expStr = num.toExponential(6);
        // Clean up trailing zeroes in mantissa (e.g. 1.000000e+15 -> 1e+15)
        return expStr.replace(/\.?0+e/, 'e');
    }
    
    // Precision format to avoid float inaccuracies e.g. 0.1 + 0.2 = 0.3000000004
    const precision = 12;
    let formatted = Number(num.toPrecision(precision)).toString();
    
    if (formatted.includes('.') && !formatted.includes('e')) {
        formatted = formatted.replace(/\.?0+$/, ''); // Remove trailing zeros
    }
    return formatted;
}

// Calculator Operations logic
function appendNumber(num) {
    if (currentInput === '0' || shouldResetDisplay) {
        if (expression.endsWith('=')) {
            expression = '';
        }
        currentInput = num;
        shouldResetDisplay = false;
    } else {
        // Prevent typing too many numbers (prevent overflow)
        if (currentInput.length < 20) {
            currentInput += num;
        }
    }
    updateDisplay();
}

function appendDecimal() {
    if (shouldResetDisplay) {
        if (expression.endsWith('=')) {
            expression = '';
        }
        currentInput = '0.';
        shouldResetDisplay = false;
        updateDisplay();
        return;
    }
    if (!currentInput.includes('.')) {
        currentInput += '.';
        updateDisplay();
    }
}

function clearAll() {
    currentInput = '0';
    previousValue = null;
    activeOperator = null;
    expression = '';
    shouldResetDisplay = false;
    updateDisplay();
}

function handleBackspace() {
    if (expression.endsWith('=')) {
        clearAll();
        return;
    }

    if (shouldResetDisplay || currentInput === '0') {
        if (activeOperator) {
            const parts = expression.split(' ');
            if (parts.length >= 3) {
                const lastNum = parts.pop();
                const lastOp = parts.pop();
                
                expression = parts.join(' ');
                
                const opMapping = { '+': 'add', '−': 'subtract', '×': 'multiply', '÷': 'divide' };
                activeOperator = opMapping[lastOp];
                previousValue = evaluateExpressionParts(parts);
                
                currentInput = lastNum;
                shouldResetDisplay = false;
            } else if (parts.length > 0 && parts[0] !== "") {
                currentInput = parts[0];
                expression = '';
                activeOperator = null;
                previousValue = null;
                shouldResetDisplay = false;
            } else {
                clearAll();
            }
        } else {
            clearAll();
        }
    } else {
        if (currentInput.length > 1) {
            currentInput = currentInput.slice(0, -1);
        } else {
            currentInput = '0';
        }
    }
    updateDisplay();
}

function evaluateExpressionParts(parts) {
    if (parts.length === 0) return 0;
    let result = parseFloat(parts[0]);
    if (isNaN(result)) return 0;
    
    let i = 1;
    while (i < parts.length - 1) {
        const op = parts[i];
        const nextVal = parseFloat(parts[i + 1]);
        if (isNaN(nextVal)) break;
        
        if (op === '+') {
            result += nextVal;
        } else if (op === '−') {
            result -= nextVal;
        } else if (op === '×') {
            result *= nextVal;
        } else if (op === '÷') {
            if (nextVal !== 0) {
                result /= nextVal;
            } else {
                result = 0;
            }
        }
        i += 2;
    }
    return result;
}

function handlePercent() {
    const num = parseFloat(currentInput);
    if (!isNaN(num)) {
        currentInput = formatNumber(num / 100);
        updateDisplay();
    }
}

function handleNegate() {
    if (currentInput === '0') return;
    if (currentInput.startsWith('-')) {
        currentInput = currentInput.slice(1);
    } else {
        currentInput = '-' + currentInput;
    }
    updateDisplay();
}

function chooseOperator(operator) {
    if (shouldResetDisplay && activeOperator) {
        // If an operator is already active and the user clicks another one before typing,
        // just switch the operator without updating the previous value.
        activeOperator = operator;
        updateDisplay();
        return;
    }

    if (activeOperator && !shouldResetDisplay) {
        // Intermediate calculation (builds continuous expression)
        const prev = previousValue;
        const current = parseFloat(currentInput);
        if (!isNaN(prev) && !isNaN(current)) {
            let result;
            switch (activeOperator) {
                case 'add': result = prev + current; break;
                case 'subtract': result = prev - current; break;
                case 'multiply': result = prev * current; break;
                case 'divide':
                    if (current === 0) {
                        currentInput = 'Error';
                        expression = `${expression} ÷ 0`;
                        activeOperator = null;
                        shouldResetDisplay = true;
                        updateDisplay();
                        return;
                    }
                    result = prev / current;
                    break;
                default: return;
            }
            const opSymbols = { add: '+', subtract: '−', multiply: '×', divide: '÷' };
            const currentOpSymbol = opSymbols[activeOperator];
            expression = `${expression} ${currentOpSymbol} ${formatNumber(current)}`;
            previousValue = result;
        }
    } else {
        previousValue = parseFloat(currentInput);
        if (!isNaN(previousValue)) {
            expression = formatNumber(previousValue);
        }
    }
    
    activeOperator = operator;
    currentInput = '0'; // Clear the input field for the next operand
    shouldResetDisplay = true;
    updateDisplay();
}

function calculate() {
    if (activeOperator === null || shouldResetDisplay) return;
    
    const prev = previousValue;
    const current = parseFloat(currentInput);
    
    if (isNaN(prev) || isNaN(current)) return;
    
    let result;
    switch (activeOperator) {
        case 'add':
            result = prev + current;
            break;
        case 'subtract':
            result = prev - current;
            break;
        case 'multiply':
            result = prev * current;
            break;
        case 'divide':
            if (current === 0) {
                currentInput = 'Error';
                expression = `${expression} ÷ 0`;
                activeOperator = null;
                shouldResetDisplay = true;
                updateDisplay();
                return;
            }
            result = prev / current;
            break;
        default:
            return;
    }
    
    const opSymbols = { add: '+', subtract: '−', multiply: '×', divide: '÷' };
    const currentOpSymbol = opSymbols[activeOperator];
    const fullExpression = `${expression} ${currentOpSymbol} ${formatNumber(current)}`;
    const formattedResult = formatNumber(result);
    
    currentInput = formattedResult;
    expression = `${fullExpression} =`;
    addHistoryItem(fullExpression, formattedResult);
    
    activeOperator = null;
    previousValue = null;
    shouldResetDisplay = true;
    updateDisplay();
}

// Event Listeners Setup
function setupEventListeners() {
    // Buttons
    document.querySelectorAll('.btn-number').forEach(btn => {
        btn.addEventListener('click', () => {
            const val = btn.textContent;
            if (val === '.') {
                appendDecimal();
            } else {
                appendNumber(val);
            }
        });
    });

    document.querySelectorAll('.btn-operator').forEach(btn => {
        btn.addEventListener('click', () => {
            const op = btn.dataset.operator;
            chooseOperator(op);
        });
    });

    // Special Action Buttons
    document.getElementById('btn-clear').addEventListener('click', clearAll);
    document.getElementById('btn-backspace').addEventListener('click', handleBackspace);
    document.getElementById('btn-percent').addEventListener('click', handlePercent);
    document.getElementById('btn-negate').addEventListener('click', handleNegate);
    document.getElementById('btn-equals').addEventListener('click', calculate);

    // Header Controls
    themeToggleBtn.addEventListener('click', toggleTheme);
    historyToggleBtn.addEventListener('click', openHistory);
    closeHistoryBtn.addEventListener('click', closeHistory);
    clearHistoryBtn.addEventListener('click', clearHistory);

    // Keyboard support
    document.addEventListener('keydown', handleKeyboardInput);
}

// Keyboard Mapper
function handleKeyboardInput(e) {
    let key = e.key;
    
    // Prevent default actions for standard calculator shortcut keys (like '/' doing quick find, or Space clicking last button)
    if (key === '/' || key === 'Enter' || key === ' ') {
        e.preventDefault();
    }

    // Number mapping
    if (/[0-9]/.test(key)) {
        appendNumber(key);
        triggerBtnAnimation(`btn-${key}`);
        return;
    }
    
    if (key === '.') {
        appendDecimal();
        triggerBtnAnimation('btn-decimal');
        return;
    }

    // Operator mapping
    if (key === '+') {
        chooseOperator('add');
        triggerBtnAnimation('btn-add');
    } else if (key === '-') {
        chooseOperator('subtract');
        triggerBtnAnimation('btn-subtract');
    } else if (key === '*' || key.toLowerCase() === 'x') {
        chooseOperator('multiply');
        triggerBtnAnimation('btn-multiply');
    } else if (key === '/') {
        chooseOperator('divide');
        triggerBtnAnimation('btn-divide');
    }
    
    // Equals
    else if (key === 'Enter' || key === '=') {
        calculate();
        triggerBtnAnimation('btn-equals');
    }
    
    // Actions
    else if (key === 'Backspace') {
        handleBackspace();
        triggerBtnAnimation('btn-backspace');
    } else if (key === 'Escape' || key.toLowerCase() === 'c') {
        clearAll();
        triggerBtnAnimation('btn-clear');
    } else if (key === '%') {
        handlePercent();
        triggerBtnAnimation('btn-percent');
    }
}

// Visual button feedback for keyboard users
function triggerBtnAnimation(id) {
    const btn = document.getElementById(id);
    if (btn) {
        btn.classList.add('active-keyboard-press');
        // Add temporary scale & active state
        btn.style.transform = 'scale(0.92)';
        setTimeout(() => {
            btn.style.transform = '';
            btn.classList.remove('active-keyboard-press');
        }, 100);
    }
}
