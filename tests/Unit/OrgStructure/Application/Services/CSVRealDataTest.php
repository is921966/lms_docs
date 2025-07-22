<?php

declare(strict_types=1);

namespace Tests\Unit\OrgStructure\Application\Services;

use App\OrgStructure\Application\Services\CSVParser;
use PHPUnit\Framework\TestCase;

final class CSVRealDataTest extends TestCase
{
    private CSVParser $parser;

    protected function setUp(): void
    {
        $this->parser = new CSVParser();
    }

    public function testParseEmployeeDataWithCommaDelimiter(): void
    {
        $csvData = <<<CSV
tab_number,full_name,email,phone,department_id,position_id,manager_id
00001,Иванов Иван Иванович,ivanov@company.ru,+7(495)123-45-67,dept-001,pos-001,
00002,Петров Петр Петрович,petrov@company.ru,+7(495)123-45-68,dept-001,pos-002,00001
00003,Сидорова Анна Петровна,sidorova@company.ru,+7(495)123-45-69,dept-002,pos-003,00001
00004,Козлов Сергей Николаевич,kozlov@company.ru,,dept-002,pos-002,00003
CSV;

        $result = $this->parser->parse($csvData);

        $this->assertCount(4, $result);
        
        // Проверяем первого сотрудника (директор без менеджера)
        $this->assertEquals('00001', $result[0]['tab_number']);
        $this->assertEquals('Иванов Иван Иванович', $result[0]['full_name']);
        $this->assertEquals('ivanov@company.ru', $result[0]['email']);
        $this->assertEquals('+7(495)123-45-67', $result[0]['phone']);
        $this->assertEquals('dept-001', $result[0]['department_id']);
        $this->assertEquals('pos-001', $result[0]['position_id']);
        $this->assertEquals('', $result[0]['manager_id']);
        
        // Проверяем второго сотрудника (с менеджером)
        $this->assertEquals('00002', $result[1]['tab_number']);
        $this->assertEquals('Петров Петр Петрович', $result[1]['full_name']);
        $this->assertEquals('00001', $result[1]['manager_id']);
    }

    public function testParseDepartmentDataWithSemicolonDelimiter(): void
    {
        $csvData = <<<CSV
code;name;parent_code
COMPANY;ООО "Рога и Копыта";
IT;Департамент информационных технологий;COMPANY
IT-DEV;Отдел разработки;IT
IT-OPS;Отдел эксплуатации;IT
HR;Департамент по работе с персоналом;COMPANY
FIN;Финансовый департамент;COMPANY
FIN-ACC;Бухгалтерия;FIN
CSV;

        $result = $this->parser->parse($csvData, ';');

        $this->assertCount(7, $result);
        
        // Проверяем корневой департамент
        $this->assertEquals('COMPANY', $result[0]['code']);
        $this->assertEquals('ООО "Рога и Копыта"', $result[0]['name']);
        $this->assertEquals('', $result[0]['parent_code']);
        
        // Проверяем вложенный департамент
        $this->assertEquals('IT-DEV', $result[2]['code']);
        $this->assertEquals('Отдел разработки', $result[2]['name']);
        $this->assertEquals('IT', $result[2]['parent_code']);
    }

    public function testParsePositionDataWithTabDelimiter(): void
    {
        $csvData = "code\tname\tcategory\tcompetencies\n";
        $csvData .= "CEO\tГенеральный директор\tРуководство\tлидерство,стратегия,управление\n";
        $csvData .= "CTO\tТехнический директор\tРуководство\tтехлидерство,архитектура,управление\n";
        $csvData .= "DEV-SENIOR\tВедущий разработчик\tСпециалист\tphp,javascript,sql,архитектура\n";
        $csvData .= "DEV-MIDDLE\tРазработчик\tСпециалист\tphp,javascript,sql\n";
        $csvData .= "HR-HEAD\tРуководитель HR\tРуководство\tуправление,hr,рекрутинг\n";

        $result = $this->parser->parse($csvData, "\t");

        $this->assertCount(5, $result);
        
        $this->assertEquals('CEO', $result[0]['code']);
        $this->assertEquals('Генеральный директор', $result[0]['name']);
        $this->assertEquals('Руководство', $result[0]['category']);
        $this->assertEquals('лидерство,стратегия,управление', $result[0]['competencies']);
        
        $this->assertEquals('DEV-SENIOR', $result[2]['code']);
        $this->assertEquals('Ведущий разработчик', $result[2]['name']);
        $this->assertEquals('php,javascript,sql,архитектура', $result[2]['competencies']);
    }

    public function testParseWithQuotedFields(): void
    {
        $csvData = <<<CSV
tab_number,full_name,email,department_id,position_id
00005,"Смирнов, Александр Викторович","smirnov@company.ru","dept-003","pos-004"
00006,"O'Brien, John","obrien@company.ru","dept-003","pos-005"
00007,"Фамилия с ""кавычками""","test@company.ru","dept-003","pos-005"
CSV;

        $result = $this->parser->parse($csvData);

        $this->assertCount(3, $result);
        
        // Проверяем обработку запятых в кавычках
        $this->assertEquals('Смирнов, Александр Викторович', $result[0]['full_name']);
        
        // Проверяем обработку апострофов
        $this->assertEquals("O'Brien, John", $result[1]['full_name']);
        
        // Проверяем обработку двойных кавычек
        $this->assertEquals('Фамилия с "кавычками"', $result[2]['full_name']);
    }

    public function testParseWithMixedLineEndings(): void
    {
        // Смешанные окончания строк (Windows \r\n, Unix \n, Mac \r)
        $csvData = "tab_number,full_name,department_id,position_id\r\n";
        $csvData .= "00008,Первый сотрудник,dept-001,pos-001\n";
        $csvData .= "00009,Второй сотрудник,dept-001,pos-002\r";
        $csvData .= "00010,Третий сотрудник,dept-002,pos-003";

        $result = $this->parser->parse($csvData);

        $this->assertCount(3, $result);
        $this->assertEquals('00008', $result[0]['tab_number']);
        $this->assertEquals('00009', $result[1]['tab_number']);
        $this->assertEquals('00010', $result[2]['tab_number']);
    }

    public function testParseWithEmptyFields(): void
    {
        $csvData = <<<CSV
tab_number,full_name,email,phone,department_id,position_id,manager_id
00011,Только имя,,,,dept-001,pos-001,
00012,С email,test@company.ru,,,dept-001,pos-002,00011
00013,С телефоном,,+7(495)111-22-33,,dept-002,pos-003,00011
CSV;

        $result = $this->parser->parse($csvData);

        $this->assertCount(3, $result);
        
        // Проверяем, что пустые поля сохраняются как пустые строки
        $this->assertEquals('', $result[0]['email']);
        $this->assertEquals('', $result[0]['phone']);
        $this->assertEquals('', $result[0]['manager_id']);
        
        $this->assertEquals('test@company.ru', $result[1]['email']);
        $this->assertEquals('', $result[1]['phone']);
        
        $this->assertEquals('', $result[2]['email']);
        $this->assertEquals('+7(495)111-22-33', $result[2]['phone']);
    }

    public function testParseRealWorldScenario(): void
    {
        // Реальный сценарий с разными типами данных
        $csvData = <<<CSV
tab_number,full_name,email,phone,department_id,position_id,manager_id
00001,Генеральный директор,ceo@company.ru,+7(495)100-00-00,COMPANY,CEO,
00002,Технический директор,cto@company.ru,+7(495)100-00-01,IT,CTO,00001
00003,HR директор,hr@company.ru,+7(495)100-00-02,HR,HR-HEAD,00001
00004,Финансовый директор,cfo@company.ru,+7(495)100-00-03,FIN,CFO,00001
00005,Руководитель разработки,dev-lead@company.ru,+7(495)100-00-10,IT-DEV,DEV-LEAD,00002
00006,Ведущий разработчик,senior1@company.ru,,IT-DEV,DEV-SENIOR,00005
00007,Ведущий разработчик,senior2@company.ru,,IT-DEV,DEV-SENIOR,00005
00008,Разработчик,dev1@company.ru,,IT-DEV,DEV-MIDDLE,00006
00009,Разработчик,dev2@company.ru,,IT-DEV,DEV-MIDDLE,00006
00010,Младший разработчик,junior1@company.ru,,IT-DEV,DEV-JUNIOR,00007
CSV;

        $result = $this->parser->parse($csvData);

        $this->assertCount(10, $result);
        
        // Проверяем иерархию
        $ceo = $result[0];
        $this->assertEquals('', $ceo['manager_id'], 'CEO не должен иметь менеджера');
        
        $cto = $result[1];
        $this->assertEquals('00001', $cto['manager_id'], 'CTO подчиняется CEO');
        
        $devLead = $result[4];
        $this->assertEquals('00002', $devLead['manager_id'], 'Dev Lead подчиняется CTO');
        
        $senior1 = $result[5];
        $this->assertEquals('00005', $senior1['manager_id'], 'Senior подчиняется Dev Lead');
    }
} 