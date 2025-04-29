// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DegreeCertificateManager {
    address public admin;

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Chi admin moi co quyen.");
        _;
    }

    struct Degree {
        string degreeType;        // Cử nhân, Thạc sĩ, Chứng chỉ, ...
        string courseName;        // Tên khóa học
        string department;        // Khoa: CNTT, Kinh te, ...
        string graduationDate;    // Ngày tốt nghiệp
        bool isRevoked;           // Trạng thái bị thu hồi hay chưa
    }

    struct Student {
        string studentName;
        string studentID;
        Degree[] degrees;         // Danh sách các văn bằng
    }

    mapping(string => Student) public students;

    event DegreeAdded(string studentID, string degreeType);
    event DegreeRevoked(string studentID, uint index);

    // ✅ Cấp văn bằng mới cho sinh viên
    function addDegreeForStudent(
        string memory _studentName,
        string memory _studentID,
        string memory _degreeType,
        string memory _courseName,
        string memory _department,
        string memory _graduationDate
    ) public onlyAdmin {
        Student storage s = students[_studentID];

        // Nếu sinh viên mới, thêm thông tin tên
        if (bytes(s.studentID).length == 0) {
            s.studentName = _studentName;
            s.studentID = _studentID;
        }

        // Thêm văn bằng mới
        s.degrees.push(Degree({
            degreeType: _degreeType,
            courseName: _courseName,
            department: _department,
            graduationDate: _graduationDate,
            isRevoked: false
        }));

        emit DegreeAdded(_studentID, _degreeType);
    }

    // ✅ Lấy thông tin văn bằng theo chỉ số
    function getDegreeByIndex(string memory _studentID, uint index)
        public
        view
        returns (
            string memory studentName,
            string memory degreeType,
            string memory courseName,
            string memory department,
            string memory graduationDate,
            bool isValid
        )
    {
        require(bytes(students[_studentID].studentID).length != 0, "Sinh vien khong ton tai");
        require(index < students[_studentID].degrees.length, "Chi so khong hop le");

        Student storage s = students[_studentID];
        Degree storage d = s.degrees[index];

        return (
            s.studentName,
            d.degreeType,
            d.courseName,
            d.department,
            d.graduationDate,
            !d.isRevoked
        );
    }

    // ✅ Thu hồi văn bằng theo chỉ số
    function revokeDegree(string memory _studentID, uint index) public onlyAdmin {
        require(bytes(students[_studentID].studentID).length != 0, "Sinh vien khong ton tai");
        require(index < students[_studentID].degrees.length, "Chi so khong hop le");

        students[_studentID].degrees[index].isRevoked = true;
        emit DegreeRevoked(_studentID, index);
    }

    // ✅ Lấy tổng số văn bằng của sinh viên (phục vụ frontend)
    function getTotalDegrees(string memory _studentID) public view returns (uint) {
        return students[_studentID].degrees.length;
    }

    // ✅ Kiểm tra hợp lệ một văn bằng cụ thể
    function verifyDegree(string memory _studentID, uint index)
        public
        view
        returns (bool isValid)
    {
        require(index < students[_studentID].degrees.length, "Chi so khong hop le");
        return !students[_studentID].degrees[index].isRevoked;
    }

    // ✅ Xem địa chỉ admin
    function getAdmin() public view returns (address) {
        return admin;
    }
}
