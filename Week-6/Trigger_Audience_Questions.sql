
-- ================================================
-- 📘 Trigger-Based Audience Questions (SQL Format)
-- ================================================

-- Q1: What will happen if we insert a new row in the Products table?
-- A) The stock remains unchanged.
-- B) A message is printed due to the INSERT trigger.
-- C) A row is deleted from another table.
-- D) Nothing happens.

-- Q2: What are 'magic tables' in the context of triggers?
-- A) Temporary tables for intermediate results.
-- B) Special system tables that store old and new data during DML trigger execution.
-- C) Views for backup.
-- D) Cursors used in triggers.

-- Q3: Which of the following cannot be performed in an INSTEAD OF trigger?
-- A) Prevent deletion of important data.
-- B) Modify a row before actual UPDATE.
-- C) Create a table.
-- D) Log audit info in another table.

-- Q4: How many types of triggers are there in T-SQL?
-- A) One
-- B) Two
-- C) Three
-- D) Four

-- Q5: What’s the main difference between a trigger and a constraint?
-- A) Triggers are faster.
-- B) Constraints are dynamic.
-- C) Triggers allow logic processing, constraints do not.
-- D) Constraints can track data changes.

-- Q6: What is the purpose of AFTER trigger?
-- A) Acts before data change happens.
-- B) Rolls back data immediately.
-- C) Executes logic after the data change has occurred.
-- D) Avoids constraint checking.

-- Q7: Which table stores the new values in an UPDATE trigger?
-- A) INSERTED
-- B) UPDATED
-- C) DELETED
-- D) SYS.TRIGGERS

-- Q8: Can a trigger call another trigger?
-- A) No
-- B) Yes, but only once
-- C) Yes, through nesting
-- D) Only in MySQL

-- Q9: What happens if an error occurs inside a trigger?
-- A) It’s ignored
-- B) Only trigger rolls back
-- C) The entire transaction may be rolled back
-- D) Trigger becomes inactive

-- Q10: Which statement is used to remove a trigger?
-- A) DROP TRIGGER trigger_name
-- B) DELETE TRIGGER trigger_name
-- C) REMOVE TRIGGER trigger_name
-- D) ERASE TRIGGER trigger_name
