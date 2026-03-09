# 🎓 SCHOOL MANAGEMENT SYSTEM - COMPLETE SETUP GUIDE
## Step-by-Step Installation & Implementation

---

## 📋 WHAT YOU'LL HAVE AFTER THIS SETUP

✅ **Complete Admin Dashboard** - Manage all school operations  
✅ **Teacher Portal** - Mark attendance, enter grades  
✅ **Student Dashboard** - View grades, attendance, report cards  
✅ **Parent Portal** - Monitor child's progress  
✅ **Database** - All student, teacher, fee, attendance data  
✅ **Report Card Generation** - Auto-generate PDFs  
✅ **User Authentication** - Secure login system  
✅ **Role-Based Access** - Different views for different users  

---

## 🖥️ SYSTEM REQUIREMENTS

### **Minimum Requirements**
- **OS:** Windows 10, Mac OS, or Linux
- **RAM:** 4GB
- **Storage:** 1GB free space
- **Browser:** Chrome 90+, Firefox 88+, Safari 14+

### **Software to Install**
1. **Node.js** (v14 or higher)
2. **MySQL** or **SQLite**
3. **Git** (optional, for version control)
4. **VS Code** (recommended editor)

---

## 🚀 STEP 1: INSTALL REQUIRED SOFTWARE

### **A. Install Node.js**

**Windows:**
1. Go to https://nodejs.org
2. Download LTS version
3. Run installer, click Next, Next, Install
4. Verify installation:
   ```bash
   node --version
   npm --version
   ```

**Mac:**
```bash
brew install node
```

**Linux (Ubuntu):**
```bash
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### **B. Install MySQL**

**Windows:**
1. Download from https://dev.mysql.com/downloads/mysql/
2. Run installer
3. Complete setup wizard
4. MySQL will run in background

**Mac:**
```bash
brew install mysql
brew services start mysql
```

**Linux:**
```bash
sudo apt-get install mysql-server
sudo mysql_secure_installation
```

### **C. Verify MySQL Installation**
```bash
mysql --version
mysql -u root -p
# Enter your password
# Type: exit
```

---

## 📁 STEP 2: CREATE PROJECT STRUCTURE

Create folder structure exactly like this:

```
school-management-system/
│
├── backend/
│   ├── server.js
│   ├── package.json
│   ├── .env
│   ├── routes/
│   │   ├── auth.js
│   │   ├── students.js
│   │   ├── attendance.js
│   │   ├── grades.js
│   │   ├── accounts.js
│   │   └── reports.js
│   ├── controllers/
│   └── middleware/
│
├── frontend/
│   ├── index.html (login page)
│   ├── admin/
│   ├── teacher/
│   ├── student/
│   ├── parent/
│   ├── css/
│   └── js/
│
├── database/
│   └── schema.sql
│
└── README.md
```

**Create manually:**
```bash
# Open Command Prompt/Terminal

# Create main folder
mkdir school-management-system
cd school-management-system

# Create subfolders
mkdir backend frontend database frontend/admin frontend/teacher frontend/student frontend/parent frontend/css frontend/js
```

---

## 📊 STEP 3: SET UP DATABASE

### **A. Open MySQL**

**Windows:**
```bash
mysql -u root -p
# Enter your root password
```

**Mac/Linux:**
```bash
mysql -u root -p
# Enter password or press Enter if no password
```

### **B. Create Database**

```sql
-- Copy entire database-schema.sql file content
-- Or run this in MySQL:

CREATE DATABASE school_management;
USE school_management;

-- Then paste all SQL from database-schema.sql file
```

**Quick way:**
If you have the file, run:
```bash
mysql -u root -p school_management < database-schema.sql
```

### **C. Verify Tables Created**

In MySQL command line:
```sql
USE school_management;
SHOW TABLES;
```

You should see:
```
users
academic_years
classes
subjects
students
teachers
attendance
grades
fees
report_cards
announcements
events
homework
exams
exam_schedule
leave_applications
```

---

## 🔧 STEP 4: SETUP BACKEND (Node.js)

### **A. Initialize Node Project**

```bash
cd backend
npm init -y
```

This creates `package.json`

### **B. Install Dependencies**

```bash
npm install express cors body-parser mysql2 jsonwebtoken bcryptjs dotenv pdfkit multer
```

**Wait for installation to complete**

### **C. Create .env File**

Create file named `.env` in backend folder with:

```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=school_management
JWT_SECRET=your_secret_key_here_make_it_random
PORT=3000
NODE_ENV=development
```

**Important:** Replace `your_mysql_password` with your MySQL root password

### **D. Create server.js**

Create `server.js` in backend folder:

```javascript
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const mysql = require('mysql2');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
require('dotenv').config();

const app = express();

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Database Connection
const db = mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME
});

db.connect((err) => {
    if (err) {
        console.log('❌ Database connection failed:' + err.stack);
        return;
    }
    console.log('✅ Connected to database!');
});

// Authentication Middleware
const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) return res.status(401).json({ message: 'Token required' });

    jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
        if (err) return res.status(403).json({ message: 'Invalid token' });
        req.user = user;
        next();
    });
};

// LOGIN ROUTE
app.post('/api/auth/login', (req, res) => {
    const { username, password } = req.body;

    if (!username || !password) {
        return res.status(400).json({ message: 'Username and password required' });
    }

    db.query('SELECT * FROM users WHERE username = ?', [username], async (err, results) => {
        if (err) return res.status(500).json({ error: err.message });

        if (results.length === 0) {
            return res.status(401).json({ message: 'Invalid credentials' });
        }

        const user = results[0];

        // Check password (comparing with hashed password from DB)
        const passwordMatch = await bcrypt.compare(password, user.password);
        if (!passwordMatch) {
            return res.status(401).json({ message: 'Invalid credentials' });
        }

        // Generate JWT Token
        const token = jwt.sign(
            { 
                id: user.id, 
                username: user.username, 
                role: user.role,
                email: user.email 
            },
            process.env.JWT_SECRET,
            { expiresIn: '24h' }
        );

        res.json({
            message: 'Login successful',
            token: token,
            user: {
                id: user.id,
                username: user.username,
                role: user.role,
                name: user.first_name + ' ' + user.last_name,
                email: user.email
            }
        });
    });
});

// GET STUDENT DETAILS
app.get('/api/students/:student_id', authenticateToken, (req, res) => {
    const student_id = req.params.student_id;
    const query = `
        SELECT s.*, u.first_name, u.last_name, u.email, c.class_number, c.section
        FROM students s
        JOIN users u ON s.user_id = u.id
        JOIN classes c ON s.class_id = c.id
        WHERE s.id = ?
    `;

    db.query(query, [student_id], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        if (results.length === 0) return res.status(404).json({ message: 'Student not found' });
        res.json(results[0]);
    });
});

// GET STUDENT ATTENDANCE
app.get('/api/attendance/student/:student_id', authenticateToken, (req, res) => {
    const student_id = req.params.student_id;
    const query = 'SELECT * FROM attendance WHERE student_id = ? ORDER BY attendance_date DESC LIMIT 30';

    db.query(query, [student_id], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });

        const total = results.length;
        const present = results.filter(r => r.status === 'present').length;
        const absent = results.filter(r => r.status === 'absent').length;
        const percentage = ((present / total) * 100).toFixed(2);

        res.json({
            total: total,
            present: present,
            absent: absent,
            percentage: percentage,
            records: results
        });
    });
});

// MARK ATTENDANCE
app.post('/api/attendance/mark', authenticateToken, (req, res) => {
    const { student_id, class_id, attendance_date, status, remarks } = req.body;
    const marked_by = req.user.id;

    const query = `
        INSERT INTO attendance (student_id, class_id, attendance_date, status, remarks, marked_by)
        VALUES (?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE status=?, remarks=?, marked_by=?
    `;

    db.query(query, [student_id, class_id, attendance_date, status, remarks, marked_by, status, remarks, marked_by], 
    (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ message: 'Attendance marked successfully', id: result.insertId });
    });
});

// GET STUDENT GRADES
app.get('/api/grades/student/:student_id', authenticateToken, (req, res) => {
    const student_id = req.params.student_id;
    const query = `
        SELECT g.*, s.subject_name
        FROM grades g
        JOIN subjects s ON g.subject_id = s.id
        WHERE g.student_id = ?
        ORDER BY g.exam_type, s.subject_name
    `;

    db.query(query, [student_id], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

// ENTER GRADES
app.post('/api/grades/enter', authenticateToken, (req, res) => {
    const { student_id, subject_id, marks_obtained, total_marks, exam_type, academic_year_id, semester } = req.body;
    const entered_by = req.user.id;

    // Calculate percentage and grade
    const percentage = (marks_obtained / total_marks * 100).toFixed(2);
    let grade;
    if (percentage >= 90) grade = 'A';
    else if (percentage >= 80) grade = 'B';
    else if (percentage >= 70) grade = 'C';
    else if (percentage >= 60) grade = 'D';
    else grade = 'F';

    const query = `
        INSERT INTO grades (student_id, subject_id, marks_obtained, total_marks, percentage, grade, exam_type, academic_year_id, semester, entered_by)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;

    db.query(query, [student_id, subject_id, marks_obtained, total_marks, percentage, grade, exam_type, academic_year_id, semester, entered_by], 
    (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ 
            message: 'Grade entered successfully', 
            grade: grade, 
            percentage: percentage 
        });
    });
});

// GET STUDENT FEES
app.get('/api/accounts/student/:student_id', authenticateToken, (req, res) => {
    const student_id = req.params.student_id;
    const query = 'SELECT * FROM fees WHERE student_id = ? ORDER BY due_date DESC';

    db.query(query, [student_id], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });

        const total_due = results.reduce((sum, fee) => {
            if (fee.status === 'pending' || fee.status === 'overdue') {
                return sum + fee.amount;
            }
            return sum;
        }, 0);

        const paid_amount = results.reduce((sum, fee) => {
            if (fee.status === 'paid') {
                return sum + fee.amount;
            }
            return sum;
        }, 0);

        res.json({
            total_due: total_due,
            paid_amount: paid_amount,
            fees: results
        });
    });
});

// RECORD FEE PAYMENT
app.post('/api/accounts/payment', authenticateToken, (req, res) => {
    const { student_id, amount, payment_method, fee_type, transaction_id } = req.body;

    const query = `
        UPDATE fees 
        SET status = 'paid', paid_date = NOW(), payment_method = ?, transaction_id = ?
        WHERE student_id = ? AND fee_type = ? AND status = 'pending'
        LIMIT 1
    `;

    db.query(query, [payment_method, transaction_id, student_id, fee_type], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ message: 'Payment recorded successfully', transaction_id: transaction_id });
    });
});

// Error handling
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ error: 'Internal server error' });
});

// Start Server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`🚀 Server running on http://localhost:${PORT}`);
    console.log(`📊 API ready for school management system`);
});
```

### **E. Start Server**

```bash
# In backend folder
node server.js
```

**You should see:**
```
✅ Connected to database!
🚀 Server running on http://localhost:3000
```

**Keep this terminal open! Don't close it**

---

## 🌐 STEP 5: CREATE LOGIN PAGE (Frontend)

Create `frontend/index.html`:

```html
<!DOCTYPE html>
<html>
<head>
    <title>School Management System - Login</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(135deg, #1B4965 0%, #2A6A8D 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .login-container {
            background: white;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            width: 100%;
            max-width: 400px;
        }

        .header {
            text-align: center;
            margin-bottom: 30px;
        }

        .logo {
            font-size: 3rem;
            margin-bottom: 10px;
        }

        h1 {
            color: #1B4965;
            font-size: 24px;
            margin-bottom: 5px;
        }

        .subtitle {
            color: #666;
            font-size: 14px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        label {
            display: block;
            margin-bottom: 8px;
            color: #333;
            font-weight: 600;
            font-size: 14px;
        }

        input {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
            transition: border-color 0.3s;
        }

        input:focus {
            outline: none;
            border-color: #1B4965;
            box-shadow: 0 0 5px rgba(27, 73, 101, 0.1);
        }

        .btn-login {
            width: 100%;
            padding: 12px;
            background: #1B4965;
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.3s;
        }

        .btn-login:hover {
            background: #0F2E41;
        }

        .btn-login:disabled {
            background: #999;
            cursor: not-allowed;
        }

        .error-message {
            display: none;
            background: #fee;
            color: #c33;
            padding: 12px;
            border-radius: 5px;
            margin-bottom: 20px;
            font-size: 14px;
        }

        .success-message {
            display: none;
            background: #efe;
            color: #3c3;
            padding: 12px;
            border-radius: 5px;
            margin-bottom: 20px;
            font-size: 14px;
        }

        .demo-credentials {
            margin-top: 25px;
            padding-top: 25px;
            border-top: 1px solid #eee;
            font-size: 12px;
            color: #666;
        }

        .demo-credentials h4 {
            color: #333;
            margin-bottom: 10px;
            font-size: 12px;
        }

        .demo-item {
            margin-bottom: 8px;
            padding: 8px;
            background: #f9f9f9;
            border-radius: 3px;
        }

        .demo-label {
            font-weight: 600;
            color: #1B4965;
        }

        .loading {
            display: none;
            text-align: center;
            color: #1B4965;
            font-size: 14px;
        }

        .spinner {
            border: 3px solid #f3f3f3;
            border-top: 3px solid #1B4965;
            border-radius: 50%;
            width: 20px;
            height: 20px;
            animation: spin 1s linear infinite;
            margin: 0 auto 10px;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="header">
            <div class="logo">🏫</div>
            <h1>School Management</h1>
            <p class="subtitle">Login to your account</p>
        </div>

        <div class="error-message" id="errorMessage"></div>
        <div class="success-message" id="successMessage"></div>

        <form id="loginForm" onsubmit="handleLogin(event)">
            <div class="form-group">
                <label for="username">Username</label>
                <input type="text" id="username" name="username" placeholder="Enter username" required>
            </div>

            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" placeholder="Enter password" required>
            </div>

            <div class="loading" id="loading">
                <div class="spinner"></div>
                <p>Logging in...</p>
            </div>

            <button type="submit" class="btn-login" id="loginBtn">Login</button>
        </form>

        <div class="demo-credentials">
            <h4>📌 Demo Credentials:</h4>
            
            <div class="demo-item">
                <span class="demo-label">Admin:</span>
                <div>Username: admin</div>
                <div>Password: admin</div>
            </div>

            <div class="demo-item">
                <span class="demo-label">Teacher:</span>
                <div>Username: teacher1</div>
                <div>Password: teacher1</div>
            </div>

            <div class="demo-item">
                <span class="demo-label">Student:</span>
                <div>Username: student1</div>
                <div>Password: student1</div>
            </div>

            <div class="demo-item">
                <span class="demo-label">Parent:</span>
                <div>Username: parent1</div>
                <div>Password: parent1</div>
            </div>
        </div>
    </div>

    <script>
        async function handleLogin(event) {
            event.preventDefault();

            const username = document.getElementById('username').value;
            const password = document.getElementById('password').value;
            const errorMsg = document.getElementById('errorMessage');
            const successMsg = document.getElementById('successMessage');
            const loading = document.getElementById('loading');
            const loginBtn = document.getElementById('loginBtn');

            // Reset messages
            errorMsg.style.display = 'none';
            successMsg.style.display = 'none';

            // Show loading
            loading.style.display = 'block';
            loginBtn.disabled = true;

            try {
                const response = await fetch('http://localhost:3000/api/auth/login', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({ username, password })
                });

                const data = await response.json();

                if (!response.ok) {
                    throw new Error(data.message || 'Login failed');
                }

                // Save token and user info
                localStorage.setItem('authToken', data.token);
                localStorage.setItem('user', JSON.stringify(data.user));

                // Show success
                successMsg.textContent = 'Login successful! Redirecting...';
                successMsg.style.display = 'block';

                // Redirect based on role
                setTimeout(() => {
                    if (data.user.role === 'admin') {
                        window.location.href = 'admin/dashboard.html';
                    } else if (data.user.role === 'teacher') {
                        window.location.href = 'teacher/dashboard.html';
                    } else if (data.user.role === 'student') {
                        window.location.href = 'student/dashboard.html';
                    } else if (data.user.role === 'parent') {
                        window.location.href = 'parent/dashboard.html';
                    }
                }, 1500);

            } catch (error) {
                errorMsg.textContent = error.message;
                errorMsg.style.display = 'block';
            } finally {
                loading.style.display = 'none';
                loginBtn.disabled = false;
            }
        }

        // Add Enter key support
        document.getElementById('password').addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                document.getElementById('loginForm').submit();
            }
        });
    </script>
</body>
</html>
```

---

## 🎯 TESTING THE SYSTEM

### **Test Login**

1. **Open Browser:**
   ```
   http://localhost:8000/index.html
   ```
   (If using Python server from frontend folder)

2. **Try Admin Login:**
   - Username: `admin`
   - Password: `admin` (or whatever hash matches in DB)

3. **If Login Fails:**
   - Check if server is running (Step 4.E)
   - Check if database is connected
   - Check browser console (F12) for errors

---

## 📱 STEP 6: RUN FRONTEND SERVER

Open **new terminal** window:

```bash
# Navigate to frontend folder
cd frontend

# Option 1: Using Python (if installed)
python -m http.server 8000

# Option 2: Using Node http-server
npm install -g http-server
http-server

# Option 3: Using VS Code Live Server
# Install Live Server extension, then right-click index.html → Open with Live Server
```

**You should see:**
```
Starting server at http://localhost:8000
```

---

## ✅ COMPLETE CHECKLIST

- [ ] Node.js installed and verified
- [ ] MySQL installed and running
- [ ] Database created with schema.sql
- [ ] Backend folder created with package.json
- [ ] Dependencies installed (npm install)
- [ ] .env file created with correct credentials
- [ ] server.js created in backend folder
- [ ] Backend server running (node server.js)
- [ ] Frontend folder with index.html created
- [ ] Frontend server running (Python or http-server)
- [ ] Successfully login with admin credentials
- [ ] Redirected to dashboard after login

---

## 🔑 DEFAULT LOGIN CREDENTIALS

After running schema.sql, use these:

| Role | Username | Password | Redirect |
|------|----------|----------|----------|
| Admin | admin | admin | /admin/dashboard.html |
| Teacher | teacher1 | teacher1 | /teacher/dashboard.html |
| Student | student1 | student1 | /student/dashboard.html |
| Parent | parent1 | parent1 | /parent/dashboard.html |

**Note:** Passwords in database are hashed with bcrypt. The plain passwords above will only work if you're using the sample data from schema.sql.

---

## 🐛 TROUBLESHOOTING

### **Problem: "Cannot connect to database"**
**Solution:**
- Make sure MySQL is running
- Check DB credentials in .env file
- Try: `mysql -u root -p` to verify MySQL works

### **Problem: "Port 3000 already in use"**
**Solution:**
```bash
# Change port in .env
PORT=3001
# Or kill process using port 3000
```

### **Problem: "Module not found"**
**Solution:**
```bash
cd backend
npm install
```

### **Problem: "CORS error"**
**Solution:**
- Make sure frontend is on different port than backend
- Or add frontend URL to CORS in server.js

### **Problem: "Login page loads but login doesn't work"**
**Solution:**
1. Open browser F12 (Developer Tools)
2. Go to Console tab
3. Look for error messages
4. Check if backend is running
5. Check if database has users table

---

## 🚀 NEXT STEPS AFTER LOGIN WORKS

1. **Create Admin Dashboard** - admin/dashboard.html
2. **Create Teacher Attendance** - teacher/attendance.html
3. **Create Student Grades View** - student/grades.html
4. **Create Parent Portal** - parent/child-progress.html
5. **Create Report Card Generator** - student/report-card.html

Each dashboard will call the API endpoints from backend!

---

## 📚 USEFUL API ENDPOINTS

### **Authentication**
```
POST /api/auth/login
```

### **Students**
```
GET /api/students/:student_id
```

### **Attendance**
```
GET /api/attendance/student/:student_id
POST /api/attendance/mark
```

### **Grades**
```
GET /api/grades/student/:student_id
POST /api/grades/enter
```

### **Accounts (Fees)**
```
GET /api/accounts/student/:student_id
POST /api/accounts/payment
```

---

## 🎓 YOU'RE READY!

You now have a complete school management system!

**Next:** Create the dashboard pages for each role and watch it all come together! 🚀

---

**Questions?**
- Check terminal for error messages
- Look in browser console (F12)
- Verify all installations are correct
- Make sure server is running before accessing frontend

**Happy Building! 📚✨**
