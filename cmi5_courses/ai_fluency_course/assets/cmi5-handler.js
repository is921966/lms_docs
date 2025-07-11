let cmi5;

window.onload = function() {
    if (window.Cmi5) {
        cmi5 = new Cmi5();
        cmi5.initialize().then(() => {
            console.log('Cmi5 initialized');
            sendStatement('initialized');
        }).catch(err => {
            console.log('Running in standalone mode');
        });
    }
};

function complete() {
    sendStatement('completed');
    alert('Урок завершен!');
    if (cmi5) {
        cmi5.terminate();
    }
}

function submitTest() {
    // Здесь добавьте логику проверки ответов
    const score = 0.8; // Пример
    sendStatement('completed', { score: score, passed: score >= 0.75 });
    alert('Тест завершен! Результат: ' + (score * 100) + '%');
    if (cmi5) {
        cmi5.terminate();
    }
}

function sendStatement(verb, result = {}) {
    if (!cmi5) return;
    
    const statement = {
        verb: {
            id: `http://adlnet.gov/expapi/verbs/${verb}`,
            display: { "en-US": verb }
        },
        object: {
            id: window.location.href,
            definition: {
                name: { "ru": document.title }
            }
        }
    };
    
    if (verb === 'completed') {
        statement.result = {
            completion: true,
            success: result.passed !== undefined ? result.passed : true
        };
        if (result.score !== undefined) {
            statement.result.score = { scaled: result.score };
        }
    }
    
    cmi5.sendStatement(statement);
}
